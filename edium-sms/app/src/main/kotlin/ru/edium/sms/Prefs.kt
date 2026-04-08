package ru.edium.sms

import android.content.Context
import android.content.SharedPreferences

object Prefs {
    private const val NAME = "edium_sms_prefs"
    private const val KEY_HERALD_URL = "herald_url"
    private const val KEY_API_KEY = "api_key"

    private fun prefs(ctx: Context): SharedPreferences =
        ctx.getSharedPreferences(NAME, Context.MODE_PRIVATE)

    fun getHeraldUrl(ctx: Context): String =
        prefs(ctx).getString(KEY_HERALD_URL, "") ?: ""

    fun setHeraldUrl(ctx: Context, url: String) =
        prefs(ctx).edit().putString(KEY_HERALD_URL, url).apply()

    fun getApiKey(ctx: Context): String =
        prefs(ctx).getString(KEY_API_KEY, "") ?: ""

    fun setApiKey(ctx: Context, key: String) =
        prefs(ctx).edit().putString(KEY_API_KEY, key).apply()

    fun isConfigured(ctx: Context): Boolean =
        getHeraldUrl(ctx).isNotBlank() && getApiKey(ctx).isNotBlank()
}
