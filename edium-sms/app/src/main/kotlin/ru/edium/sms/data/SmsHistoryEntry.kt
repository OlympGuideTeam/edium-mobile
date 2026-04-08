package ru.edium.sms.data

data class SmsHistoryEntry(
    val id: String,
    val phone: String,
    val text: String,
    val sentAt: Long,
    val success: Boolean,
    val error: String? = null,
)
