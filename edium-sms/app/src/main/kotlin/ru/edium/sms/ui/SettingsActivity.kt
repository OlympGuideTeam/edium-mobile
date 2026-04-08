package ru.edium.sms.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import ru.edium.sms.Prefs
import ru.edium.sms.databinding.ActivitySettingsBinding

class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.etHeraldUrl.setText(Prefs.getHeraldUrl(this))
        binding.etApiKey.setText(Prefs.getApiKey(this))

        binding.btnSave.setOnClickListener {
            val url = binding.etHeraldUrl.text.toString().trim()
            val key = binding.etApiKey.text.toString().trim()
            Prefs.setHeraldUrl(this, url)
            Prefs.setApiKey(this, key)
            finish()
        }
    }
}
