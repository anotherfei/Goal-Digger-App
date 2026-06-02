package com.example.fltr_test

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val notificationChannel = "goal_digger/notifications"
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
}
