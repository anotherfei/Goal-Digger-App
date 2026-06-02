package com.example.fltr_test

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class GoalNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val request = GoalNotificationScheduler.requestFromIntent(intent) ?: return
        GoalNotificationScheduler.showNow(context, request)
    }
}
