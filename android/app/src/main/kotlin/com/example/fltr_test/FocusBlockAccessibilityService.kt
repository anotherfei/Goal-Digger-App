package com.example.fltr_test

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class FocusBlockAccessibilityService : AccessibilityService() {
    private var lastBlockedPackage: String? = null
    private var lastBlockedAtMillis = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val foregroundPackage = event?.packageName?.toString() ?: return
        if (foregroundPackage == packageName) return
        if (!FocusBlockStore.isBlocked(this, foregroundPackage)) return

        val now = System.currentTimeMillis()
        if (foregroundPackage == lastBlockedPackage &&
            now - lastBlockedAtMillis < BLOCK_DEBOUNCE_MILLIS
        ) {
            return
        }

        lastBlockedPackage = foregroundPackage
        lastBlockedAtMillis = now
        performGlobalAction(GLOBAL_ACTION_HOME)
        Toast.makeText(
            this,
            "App blocked while your Goal Digger focus session is running.",
            Toast.LENGTH_SHORT
        ).show()
    }

    override fun onInterrupt() = Unit

    companion object {
        private const val BLOCK_DEBOUNCE_MILLIS = 750L
    }
}
