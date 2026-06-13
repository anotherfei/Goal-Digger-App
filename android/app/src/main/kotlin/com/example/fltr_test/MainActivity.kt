package com.example.fltr_test

import android.Manifest
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val notificationChannel = "goal_digger/notifications"
    private val focusBlockingChannel = "goal_digger/focus_blocking"
    private val notificationPermissionRequest = 7301
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    GoalNotificationScheduler.ensureChannels(this)
                    GoalNotificationScheduler.restoreScheduled(this)
                    result.success(GoalNotificationScheduler.areNotificationsEnabled(this))
                }

                "requestPermission" -> requestNotificationPermission(result)

                "areNotificationsEnabled" -> {
                    result.success(GoalNotificationScheduler.areNotificationsEnabled(this))
                }

                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(true)
                }

                "showNow" -> {
                    val request = notificationRequest(call.arguments)
                    if (request == null) {
                        result.error("bad_args", "Notification arguments were invalid.", null)
                    } else {
                        GoalNotificationScheduler.showNow(this, request)
                        result.success(true)
                    }
                }

                "schedule" -> {
                    val request = notificationRequest(call.arguments)
                    if (request == null) {
                        result.error("bad_args", "Notification arguments were invalid.", null)
                    } else {
                        GoalNotificationScheduler.schedule(this, request)
                        result.success(true)
                    }
                }

                "cancel" -> {
                    val id = (call.argument<Number>("id"))?.toInt()
                    if (id == null) {
                        result.error("bad_args", "Notification id was missing.", null)
                    } else {
                        GoalNotificationScheduler.cancel(this, id)
                        result.success(true)
                    }
                }

                "cancelAll" -> {
                    GoalNotificationScheduler.cancelAll(this)
                    result.success(true)
                }

                "cancelScheduled" -> {
                    GoalNotificationScheduler.cancelScheduled(this)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            focusBlockingChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isFocusBlockingServiceEnabled())
                }

                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }

                "getLaunchableApps" -> result.success(launchableApps())

                "startFocusSession" -> {
                    val packages = call.argument<List<*>>("packages")
                        .orEmpty()
                        .mapNotNull { it?.toString() }
                        .toSet()
                    val endsAtMillis =
                        call.argument<Number>("endsAtMillis")?.toLong()
                    val title = call.argument<String>("title") ?: "Focus session"

                    if (endsAtMillis == null) {
                        result.error(
                            "bad_args",
                            "The focus session end time was missing.",
                            null
                        )
                    } else {
                        val accessibilityRequired =
                            packages.isNotEmpty() &&
                                !isFocusBlockingServiceEnabled()
                        val blockingReady = when {
                            accessibilityRequired -> false
                            packages.isEmpty() -> {
                                FocusBlockStore.stop(this)
                                true
                            }
                            else -> FocusBlockStore.start(
                                this,
                                packages,
                                endsAtMillis
                            )
                        }
                        val notificationShown = blockingReady &&
                            FocusTimerNotification.show(
                                this,
                                title,
                                endsAtMillis
                            )
                        if (!notificationShown) {
                            FocusBlockStore.stop(this)
                        }
                        result.success(
                            mapOf(
                                "started" to
                                    (blockingReady && notificationShown),
                                "accessibilityRequired" to
                                    accessibilityRequired,
                                "notificationShown" to notificationShown
                            )
                        )
                    }
                }

                "stopFocusSession" -> {
                    FocusBlockStore.stop(this)
                    FocusTimerNotification.stop(this)
                    result.success(true)
                }

                "isBlockingActive" -> {
                    result.success(FocusBlockStore.isActive(this))
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != notificationPermissionRequest) return

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermissionResult?.success(granted)
        pendingPermissionResult = null
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }

        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }

        if (pendingPermissionResult != null) {
            result.error("permission_in_flight", "Notification permission is already being requested.", null)
            return
        }

        pendingPermissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            notificationPermissionRequest
        )
    }

    private fun notificationRequest(arguments: Any?): GoalNotificationRequest? {
        val map = arguments as? Map<*, *> ?: return null
        return GoalNotificationRequest.fromMap(map)
    }

    private fun openNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.parse("package:$packageName"))
        }
        startActivity(intent)
    }

    private fun isFocusBlockingServiceEnabled(): Boolean {
        val manager =
            getSystemService(ACCESSIBILITY_SERVICE) as AccessibilityManager
        return manager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK
        ).any { service ->
            val serviceInfo = service.resolveInfo.serviceInfo
            serviceInfo.packageName == packageName &&
                serviceInfo.name == FocusBlockAccessibilityService::class.java.name
        }
    }

    @Suppress("DEPRECATION")
    private fun launchableApps(): List<Map<String, Any>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
        val homeIntent = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_HOME)
        val launcherPackage = packageManager
            .resolveActivity(homeIntent, PackageManager.MATCH_DEFAULT_ONLY)
            ?.activityInfo
            ?.packageName
        val settingsPackage = packageManager
            .resolveActivity(
                Intent(Settings.ACTION_SETTINGS),
                PackageManager.MATCH_DEFAULT_ONLY
            )
            ?.activityInfo
            ?.packageName
        val accessibilitySettingsPackage = packageManager
            .resolveActivity(
                Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS),
                PackageManager.MATCH_DEFAULT_ONLY
            )
            ?.activityInfo
            ?.packageName
        val protectedPackages = listOfNotNull(
            packageName,
            launcherPackage,
            settingsPackage,
            accessibilitySettingsPackage,
            "com.android.settings",
            "com.android.systemui",
            "com.google.android.permissioncontroller"
        ).toSet()

        return packageManager
            .queryIntentActivities(launcherIntent, PackageManager.MATCH_ALL)
            .asSequence()
            .filterNot { it.activityInfo.packageName in protectedPackages }
            .distinctBy { it.activityInfo.packageName }
            .map { activity ->
                val app = mutableMapOf<String, Any>(
                    "packageName" to activity.activityInfo.packageName,
                    "label" to activity.loadLabel(packageManager).toString()
                )
                drawableToPng(activity.loadIcon(packageManager))?.let {
                    app["icon"] = it
                }
                app
            }
            .sortedBy { app ->
                app["label"].toString().lowercase(Locale.getDefault())
            }
            .toList()
    }

    private fun drawableToPng(drawable: Drawable?): ByteArray? {
        if (drawable == null) return null
        val bitmap = Bitmap.createBitmap(
            APP_ICON_SIZE_PX,
            APP_ICON_SIZE_PX,
            Bitmap.Config.ARGB_8888
        )
        return try {
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            ByteArrayOutputStream().use { stream ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            }
        } finally {
            bitmap.recycle()
        }
    }

    companion object {
        private const val APP_ICON_SIZE_PX = 96
    }
}
