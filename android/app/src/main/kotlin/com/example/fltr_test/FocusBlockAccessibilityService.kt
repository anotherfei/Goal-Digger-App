package com.example.fltr_test

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class FocusBlockAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (FocusBlockStore.shouldBlockPackage(this, packageName)) {
            performGlobalAction(GLOBAL_ACTION_HOME)
        }
    }

    override fun onInterrupt() {}
}
