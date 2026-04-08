package ru.edium.sms.data

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

object SmsHistory {
    private const val PREFS_NAME = "sms_history"
    private const val KEY_ENTRIES = "entries"
    private const val MAX_ENTRIES = 50
    private val gson = Gson()

    private val _entries = MutableStateFlow<List<SmsHistoryEntry>>(emptyList())
    val entries: StateFlow<List<SmsHistoryEntry>> = _entries

    fun load(ctx: Context) {
        val prefs = ctx.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_ENTRIES, null) ?: return
        val type = object : TypeToken<List<SmsHistoryEntry>>() {}.type
        _entries.value = gson.fromJson(json, type) ?: emptyList()
    }

    fun add(ctx: Context, entry: SmsHistoryEntry) {
        val updated = (listOf(entry) + _entries.value).take(MAX_ENTRIES)
        _entries.value = updated
        ctx.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_ENTRIES, gson.toJson(updated))
            .apply()
    }
}
