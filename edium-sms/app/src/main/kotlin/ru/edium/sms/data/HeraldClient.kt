package ru.edium.sms.data

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.util.concurrent.TimeUnit

class HeraldClient(
    private val baseUrl: String,
    private val apiKey: String,
) {
    private val gson = Gson()
    private val http = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    private val json = "application/json".toMediaType()

    /** Возвращает список ожидающих SMS-задач. */
    @Throws(IOException::class)
    fun fetchPendingTasks(): List<SmsTask> {
        val request = Request.Builder()
            .url("${baseUrl.trimEnd('/')}/herald/v1/sms/tasks")
            .header("Authorization", "Bearer $apiKey")
            .get()
            .build()

        http.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException("Herald вернул ${response.code}")
            }
            val body = response.body?.string() ?: return emptyList()
            val type = object : TypeToken<List<SmsTask>>() {}.type
            return gson.fromJson(body, type) ?: emptyList()
        }
    }

    /** Подтверждает выполнение задачи. */
    @Throws(IOException::class)
    fun ackTask(id: String, success: Boolean, error: String? = null) {
        data class AckBody(val success: Boolean, val error: String?)
        val body = gson.toJson(AckBody(success, error)).toRequestBody(json)

        val request = Request.Builder()
            .url("${baseUrl.trimEnd('/')}/herald/v1/sms/tasks/$id/ack")
            .header("Authorization", "Bearer $apiKey")
            .post(body)
            .build()

        http.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException("Ack вернул ${response.code}")
            }
        }
    }
}
