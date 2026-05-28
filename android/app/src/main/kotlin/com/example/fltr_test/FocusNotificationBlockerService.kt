package com.example.fltr_test

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class FocusNotificationBlockerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val notification = sbn ?: return
        if (FocusBlockStore.shouldBlockPackage(this, notification.packageName)) {
            cancelNotification(notification.key)
        }
    }
}
