package ru.edium.sms.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import ru.edium.sms.data.SmsHistoryEntry
import ru.edium.sms.databinding.ItemSmsHistoryBinding
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class SmsHistoryAdapter : ListAdapter<SmsHistoryEntry, SmsHistoryAdapter.VH>(DIFF) {

    inner class VH(val binding: ItemSmsHistoryBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val b = ItemSmsHistoryBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return VH(b)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val entry = getItem(position)
        val fmt = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        with(holder.binding) {
            tvPhone.text = entry.phone
            tvText.text = entry.text
            tvTime.text = fmt.format(Date(entry.sentAt))
            if (entry.success) {
                tvResult.text = "✓"
                tvResult.setTextColor(root.context.getColor(android.R.color.holo_green_dark))
            } else {
                tvResult.text = "✗"
                tvResult.setTextColor(root.context.getColor(android.R.color.holo_red_dark))
                tvError.text = entry.error ?: "ошибка"
                tvError.visibility = android.view.View.VISIBLE
            }
        }
    }

    companion object {
        private val DIFF = object : DiffUtil.ItemCallback<SmsHistoryEntry>() {
            override fun areItemsTheSame(a: SmsHistoryEntry, b: SmsHistoryEntry) = a.id == b.id
            override fun areContentsTheSame(a: SmsHistoryEntry, b: SmsHistoryEntry) = a == b
        }
    }
}
