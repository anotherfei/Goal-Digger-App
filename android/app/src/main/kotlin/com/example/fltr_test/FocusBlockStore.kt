package com.example.fltr_test

import android.content.Context

object FocusBlockStore {
    private const val PREFS_NAME = "goal_digger_focus_block"
    private const val KEY_BLOCKED_PACKAGES = "blocked_packages"
    private const val KEY_ENDS_AT_MILLIS = "ends_at_millis"

    fun start(
        context: Context,
        packages: Set<String>,
        endsAtMillis: Long
    ): Boolean {
        val sanitizedPackages = packages
            .map(String::trim)
            .filter(String::isNotEmpty)
            .filterNot { it == context.packageName }
            .toSet()

        if (sanitizedPackages.isEmpty() ||
            endsAtMillis <= System.currentTimeMillis()
        ) {
            stop(context)
            return false
        }

        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putStringSet(KEY_BLOCKED_PACKAGES, sanitizedPackages)
            .putLong(KEY_ENDS_AT_MILLIS, endsAtMillis)
            .apply()
        return true
    }

    fun stop(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .clear()
            .apply()
    }

    fun isActive(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val packages = prefs.getStringSet(KEY_BLOCKED_PACKAGES, emptySet()).orEmpty()
        val endsAtMillis = prefs.getLong(KEY_ENDS_AT_MILLIS, 0L)
        val active = packages.isNotEmpty() &&
            endsAtMillis > System.currentTimeMillis()
        if (!active && (packages.isNotEmpty() || endsAtMillis != 0L)) {
            stop(context)
        }
        return active
    }

    fun isBlocked(context: Context, packageName: String): Boolean {
        if (!isActive(context)) return false
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getStringSet(KEY_BLOCKED_PACKAGES, emptySet())
            .orEmpty()
            .contains(packageName)
    }
}
