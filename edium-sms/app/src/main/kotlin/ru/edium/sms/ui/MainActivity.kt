package ru.edium.sms.ui

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import ru.edium.sms.Prefs
import ru.edium.sms.data.GatewayState
import ru.edium.sms.data.GatewayStatus
import ru.edium.sms.data.SmsHistory
import ru.edium.sms.databinding.ActivityMainBinding
import ru.edium.sms.service.SmsPollerService
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val adapter = SmsHistoryAdapter()

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { granted ->
        if (granted.values.all { it }) {
            startService()
        } else {
            Toast.makeText(this, "Необходимо разрешение SEND_SMS", Toast.LENGTH_LONG).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.rvHistory.layoutManager = LinearLayoutManager(this)
        binding.rvHistory.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL))
        binding.rvHistory.adapter = adapter

        SmsHistory.load(this)

        binding.btnSettings.setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }

        binding.btnToggle.setOnClickListener {
            if (Prefs.isConfigured(this)) {
                requestPermissionsAndStart()
            } else {
                Toast.makeText(this, "Сначала настройте URL и API-ключ", Toast.LENGTH_SHORT).show()
                startActivity(Intent(this, SettingsActivity::class.java))
            }
        }

        binding.btnStop.setOnClickListener {
            SmsPollerService.stop(this)
            updateUi(running = false)
        }

        observeState()
    }

    override fun onResume() {
        super.onResume()
        // Refresh status text when returning from Settings
        val status = GatewayState.status.value
        renderStatus(status)
    }

    private fun observeState() {
        lifecycleScope.launch {
            GatewayState.status.collect { status ->
                renderStatus(status)
            }
        }
        lifecycleScope.launch {
            SmsHistory.entries.collect { entries ->
                adapter.submitList(entries)
                binding.tvHistoryEmpty.visibility = if (entries.isEmpty()) View.VISIBLE else View.GONE
            }
        }
    }

    private fun renderStatus(status: GatewayStatus) {
        val dot = binding.vStatusDot
        val tv = binding.tvStatus
        val fmt = SimpleDateFormat("HH:mm:ss", Locale.getDefault())

        when (status) {
            is GatewayStatus.Idle -> {
                dot.backgroundTintList = android.content.res.ColorStateList.valueOf(Color.GRAY)
                tv.text = if (Prefs.isConfigured(this)) {
                    "Настроен: ${Prefs.getHeraldUrl(this)} · не запущен"
                } else {
                    getString(ru.edium.sms.R.string.status_not_configured)
                }
            }
            is GatewayStatus.Connected -> {
                dot.backgroundTintList = android.content.res.ColorStateList.valueOf(Color.parseColor("#4CAF50"))
                tv.text = "Подключён · ${fmt.format(Date(status.lastPollAt))}"
            }
            is GatewayStatus.Error -> {
                dot.backgroundTintList = android.content.res.ColorStateList.valueOf(Color.parseColor("#F44336"))
                tv.text = "Ошибка: ${status.message.take(60)}"
            }
        }
    }

    private fun requestPermissionsAndStart() {
        val required = buildList {
            add(Manifest.permission.SEND_SMS)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
        val missing = required.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isEmpty()) {
            startService()
        } else {
            permissionLauncher.launch(missing.toTypedArray())
        }
    }

    private fun startService() {
        SmsPollerService.start(this)
        updateUi(running = true)
    }

    private fun updateUi(running: Boolean) {
        binding.btnToggle.isEnabled = !running
        binding.btnStop.isEnabled = running
    }
}
