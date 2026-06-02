package com.example.fltr_test

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import org.json.JSONObject

data class GoalNotificationRequest(
    val id: Int,
    val title: String,
    val body: String,
    val scheduledAtMillis: Long,
    val important: Boolean,
    val payload: String
) {
    fun toJson(): JSONObject {
        return JSONObject()
            .put("id", id)
            .put("title", title)
            .put("body", body)
            .put("scheduledAtMillis", scheduledAtMillis)
            .put("important", important)
            .put("payload", payload)
    }

    companion object {
        fun fromJson(json: JSONObject): GoalNotificationRequest {
            return GoalNotificationRequest(
                id = json.optInt("id"),
                title = json.optString("title", "Goal Digger"),
                body = json.optString("body", ""),
                scheduledAtMillis = json.optLong("scheduledAtMillis", 0L),
                important = json.optBoolean("important", false),
                payload = json.optString("payload", "")
            )
        }

        fun fromMap(map: Map<*, *>): GoalNotificationRequest? {
            val id = (map["id"] as? Number)?.toInt() ?: return null
            val title = map["title"]?.toString()?.takeIf { it.isNotBlank() }
                ?: "Goal Digger"
            val body = map["body"]?.toString() ?: ""
            val scheduledAtMillis =
                (map["scheduledAtMillis"] as? Number)?.toLong()
                    ?: System.currentTimeMillis()
            val important = map["important"] as? Boolean ?: false
            val payload = map["payload"]?.toString() ?: ""
            return GoalNotificationRequest(
                id = id,
                title = title,
                body = body,
                scheduledAtMillis = scheduledAtMillis,
                important = important,
                payload = payload
            )
        }
    }
}

object GoalNotificationScheduler {
    private const val ACTION_SHOW = "com.example.fltr_test.GOAL_NOTIFICATION_SHOW"
    private const val CHANNEL_REMINDERS = "goal_digger_reminders"
    private const val CHANNEL_IMPORTANT = "goal_digger_important"
    private const val PREFS_NAME = "goal_digger_notifications"
    private const val PREFS_SCHEDULED = "scheduled"

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val reminders = NotificationChannel(
            CHANNEL_REMINDERS,
            "Goal Digger reminders",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Daily plans, task reminders, routines, streaks, deadlines, and focus sessions."
            enableVibration(true)
        }

        val important = NotificationChannel(
            CHANNEL_IMPORTANT,
            "Goal Digger important",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Crucial Goal Digger alerts."
            enableVibration(true)
        }

        manager.createNotificationChannel(reminders)
        manager.createNotificationChannel(important)
    }

    fun areNotificationsEnabled(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return false
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val manager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            return manager.areNotificationsEnabled()
        }

        return true
    }

    fun showNow(context: Context, request: GoalNotificationRequest) {
        ensureChannels(context)
        if (!areNotificationsEnabled(context)) return

        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(request.id, buildNotification(context, request))
        removeSaved(context, request.id)
    }

    fun schedule(context: Context, request: GoalNotificationRequest) {
        ensureChannels(context)
        if (request.scheduledAtMillis <= System.currentTimeMillis() + 1000L) {
            showNow(context, request)
            return
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.set(
            AlarmManager.RTC_WAKEUP,
            request.scheduledAtMillis,
            pendingBroadcast(context, request, PendingIntent.FLAG_UPDATE_CURRENT)
        )
        saveRequest(context, request)
    }

    fun cancel(context: Context, id: Int) {
        cancelAlarm(context, id)
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(id)
        removeSaved(context, id)
    }

    fun cancelAll(context: Context) {
        cancelScheduled(context)
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancelAll()
    }

    fun cancelScheduled(context: Context) {
        for (request in savedRequests(context)) {
            cancelAlarm(context, request.id)
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .remove(PREFS_SCHEDULED)
            .apply()
    }

    private fun cancelAlarm(context: Context, id: Int) {
        val request = GoalNotificationRequest(
            id = id,
            title = "",
            body = "",
            scheduledAtMillis = 0L,
            important = false,
            payload = ""
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        pendingBroadcastOrNull(context, request)?.let { alarmManager.cancel(it) }
    }

    fun restoreScheduled(context: Context) {
        val now = System.currentTimeMillis()
        for (request in savedRequests(context)) {
            if (request.scheduledAtMillis > now) {
                schedule(context, request)
            } else {
                removeSaved(context, request.id)
            }
        }
    }

    internal fun requestFromIntent(intent: Intent): GoalNotificationRequest? {
        if (intent.action != ACTION_SHOW) return null
        return GoalNotificationRequest(
            id = intent.getIntExtra("id", 0),
            title = intent.getStringExtra("title") ?: "Goal Digger",
            body = intent.getStringExtra("body") ?: "",
            scheduledAtMillis = intent.getLongExtra("scheduledAtMillis", 0L),
            important = intent.getBooleanExtra("important", false),
            payload = intent.getStringExtra("payload") ?: ""
        )
    }

    @Suppress("DEPRECATION")
    private fun buildNotification(
        context: Context,
        request: GoalNotificationRequest
    ): Notification {
        val channelId = if (request.important) CHANNEL_IMPORTANT else CHANNEL_REMINDERS
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, channelId)
        } else {
            Notification.Builder(context)
        }

        builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(request.title)
            .setContentText(request.body)
            .setStyle(Notification.BigTextStyle().bigText(request.body))
            .setAutoCancel(true)
            .setShowWhen(true)
            .setWhen(System.currentTimeMillis())
            .setContentIntent(contentIntent(context, request.payload))

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            builder
                .setPriority(if (request.important) Notification.PRIORITY_HIGH else Notification.PRIORITY_DEFAULT)
                .setDefaults(Notification.DEFAULT_ALL)
        }

        return builder.build()
    }

    private fun pendingBroadcast(
        context: Context,
        request: GoalNotificationRequest,
        extraFlags: Int
    ): PendingIntent {
        val intent = Intent(context, GoalNotificationReceiver::class.java)
            .setAction(ACTION_SHOW)
            .putExtra("id", request.id)
            .putExtra("title", request.title)
            .putExtra("body", request.body)
            .putExtra("scheduledAtMillis", request.scheduledAtMillis)
            .putExtra("important", request.important)
            .putExtra("payload", request.payload)

        return PendingIntent.getBroadcast(
            context,
            request.id,
            intent,
            extraFlags or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun pendingBroadcastOrNull(
        context: Context,
        request: GoalNotificationRequest
    ): PendingIntent? {
        val intent = Intent(context, GoalNotificationReceiver::class.java)
            .setAction(ACTION_SHOW)
        return PendingIntent.getBroadcast(
            context,
            request.id,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun contentIntent(context: Context, payload: String): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            .putExtra("goal_digger_notification_payload", payload)
        return PendingIntent.getActivity(
            context,
            payload.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun saveRequest(context: Context, request: GoalNotificationRequest) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val root = JSONObject(prefs.getString(PREFS_SCHEDULED, "{}") ?: "{}")
        root.put(request.id.toString(), request.toJson())
        prefs.edit().putString(PREFS_SCHEDULED, root.toString()).apply()
    }

    private fun removeSaved(context: Context, id: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val root = JSONObject(prefs.getString(PREFS_SCHEDULED, "{}") ?: "{}")
        root.remove(id.toString())
        prefs.edit().putString(PREFS_SCHEDULED, root.toString()).apply()
    }

    private fun savedRequests(context: Context): List<GoalNotificationRequest> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val root = JSONObject(prefs.getString(PREFS_SCHEDULED, "{}") ?: "{}")
        val requests = mutableListOf<GoalNotificationRequest>()
        val keys = root.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val json = root.optJSONObject(key) ?: continue
            requests.add(GoalNotificationRequest.fromJson(json))
        }
        return requests
    }
}
