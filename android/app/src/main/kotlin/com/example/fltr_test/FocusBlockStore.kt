package com.example.fltr_test

import android.content.Context

object FocusBlockStore {
    private const val PREFS = "goal_digger_focus_block"
    private const val KEY_ACTIVE = "active"
    private const val KEY_MODE = "mode"
    private const val KEY_PACKAGES = "packages"
    private const val MODE_ALLOW_SELECTED = "allowSelected"

    fun start(context: Context, args: Map<String, Any?>?) {
        val policy = args?.get("appPolicy") as? Map<*, *>
        val mode = policy?.get("mode")?.toString() ?: "blockSelected"
        val packages = extractPackageNames(policy)

        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_ACTIVE, true)
            .putString(KEY_MODE, mode)
            .putStringSet(KEY_PACKAGES, packages.toMutableSet())
            .apply()
    }

    fun stop(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_ACTIVE, false)
            .remove(KEY_PACKAGES)
            .apply()
    }

    fun shouldBlockPackage(context: Context, packageName: String): Boolean {
        if (isSystemSafePackage(context, packageName)) return false

        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(KEY_ACTIVE, false)) return false

        val mode = prefs.getString(KEY_MODE, "blockSelected")
        val packages = prefs.getStringSet(KEY_PACKAGES, emptySet()).orEmpty()
        if (packages.isEmpty()) return false

        return if (mode == MODE_ALLOW_SELECTED) {
            !packages.contains(packageName)
        } else {
            packages.contains(packageName)
        }
    }

    private fun extractPackageNames(policy: Map<*, *>?): Set<String> {
        val selectedApps = policy?.get("selectedApps") as? List<*> ?: return emptySet()
        return selectedApps
            .filterIsInstance<Map<*, *>>()
            .flatMap { app ->
                val packageNames = app["androidPackageNames"]
                when (packageNames) {
                    is List<*> -> packageNames.mapNotNull { it?.toString() }
                    else -> emptyList()
                }
            }
            .filter { it.contains(".") }
            .toSet()
    }

    private fun isSystemSafePackage(context: Context, packageName: String): Boolean {
        if (packageName == context.packageName) return true
        if (packageName == "android") return true
        if (packageName.contains("launcher", ignoreCase = true)) return true

        return packageName in setOf(
            "com.android.settings",
            "com.android.systemui",
            "com.android.permissioncontroller",
            "com.android.dialer",
            "com.android.deskclock",
            "com.google.android.permissioncontroller",
            "com.google.android.packageinstaller",
            "com.google.android.dialer",
            "com.google.android.deskclock"
        )
    }
}
