package ru.edium.sms.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.telephony.SmsManager
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import ru.edium.sms.Prefs
import ru.edium.sms.R
import ru.edium.sms.data.GatewayState
import ru.edium.sms.data.GatewayStatus
import ru.edium.sms.data.HeraldClient
import ru.edium.sms.data.SmsHistory
import ru.edium.sms.data.SmsHistoryEntry
import ru.edium.sms.ui.MainActivity

class SmsPollerService : Service() {

    private val scope = CoroutineScope(Dispatchers.IO)
    private var pollerJob: Job? = null

    override fun onCreate() {
        super.onCreate()
        SmsHistory.load(this)
        startForeground(NOTIFICATION_ID, buildNotification("Ожидание задач..."))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }
        startPolling()
        return START_STICKY
    }

    override fun onDestroy() {
        GatewayState.reset()
        scope.cancel()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startPolling() {
        if (pollerJob?.isActive == true) return
        pollerJob = scope.launch {
            val client = HeraldClient(
                baseUrl = Prefs.getHeraldUrl(this@SmsPollerService),
                apiKey = Prefs.getApiKey(this@SmsPollerService),
            )
            while (isActive) {
                try {
                    pollOnce(client)
                } catch (e: Exception) {
                    Log.e(TAG, "Ошибка поллинга: ${e.message}")
                    GatewayState.update(GatewayStatus.Error(e.message ?: "неизвестная ошибка"))
                    updateNotification("Ошибка: ${e.message?.take(60)}")
                }
                delay(POLL_INTERVAL_MS)
            }
        }
    }

    private suspend fun pollOnce(client: HeraldClient) {
        val tasks = client.fetchPendingTasks()
        GatewayState.update(GatewayStatus.Connected(System.currentTimeMillis()))

        if (tasks.isEmpty()) return

        updateNotification("Отправка ${tasks.size} SMS...")
        Log.i(TAG, "Получено задач: ${tasks.size}")

        for (task in tasks) {
            var success = false
            var errMsg: String? = null
            try {
                sendSms(task.phone, task.text)
                success = true
                Log.i(TAG, "SMS отправлено: ${task.phone}")
            } catch (e: Exception) {
                errMsg = e.message
                Log.e(TAG, "Ошибка отправки SMS на ${task.phone}: $errMsg")
            }

            SmsHistory.add(
                this@SmsPollerService,
                SmsHistoryEntry(
                    id = task.id,
                    phone = task.phone,
                    text = task.text,
                    sentAt = System.currentTimeMillis(),
                    success = success,
                    error = errMsg,
                )
            )

            try {
                client.ackTask(task.id, success, errMsg)
            } catch (e: Exception) {
                Log.e(TAG, "Ошибка ack задачи ${task.id}: ${e.message}")
            }
        }

        updateNotification("Отправлено ${tasks.size} SMS")
    }

    @Suppress("DEPRECATION")
    private fun sendSms(phone: String, text: String) {
        val smsManager: SmsManager = if (android.os.Build.VERSION.SDK_INT >= 31) {
            getSystemService(SmsManager::class.java)
        } else {
            SmsManager.getDefault()
        }
        val parts = smsManager.divideMessage(text)
        if (parts.size == 1) {
            smsManager.sendTextMessage(phone, null, text, null, null)
        } else {
            smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
        }
    }

    private fun updateNotification(text: String) {
        val nm = getSystemService(NotificationManager::class.java)
        nm.notify(NOTIFICATION_ID, buildNotification(text))
    }

    private fun buildNotification(contentText: String): Notification {
        ensureChannel()
        val mainIntent = Intent(this, MainActivity::class.java)
        val pi = PendingIntent.getActivity(this, 0, mainIntent, PendingIntent.FLAG_IMMUTABLE)
        val stopIntent = Intent(this, SmsPollerService::class.java).apply { action = ACTION_STOP }
        val stopPi = PendingIntent.getService(this, 1, stopIntent, PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_sms_notification)
            .setContentTitle("Edium SMS Gateway")
            .setContentText(contentText)
            .setContentIntent(pi)
            .addAction(0, "Остановить", stopPi)
            .setOngoing(true)
            .build()
    }

    private fun ensureChannel() {
        val nm = getSystemService(NotificationManager::class.java)
        if (nm.getNotificationChannel(CHANNEL_ID) == null) {
            val ch = NotificationChannel(CHANNEL_ID, "SMS Gateway", NotificationManager.IMPORTANCE_LOW)
            nm.createNotificationChannel(ch)
        }
    }

    companion object {
        private const val TAG = "SmsPollerService"
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "edium_sms"
        private const val POLL_INTERVAL_MS = 5_000L
        const val ACTION_STOP = "ru.edium.sms.STOP"

        fun start(ctx: Context) {
            val intent = Intent(ctx, SmsPollerService::class.java)
            ctx.startForegroundService(intent)
        }

        fun stop(ctx: Context) {
            val intent = Intent(ctx, SmsPollerService::class.java).apply { action = ACTION_STOP }
            ctx.startService(intent)
        }
    }
}
