package ru.edium.sms.data

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

sealed class GatewayStatus {
    object Idle : GatewayStatus()
    data class Connected(val lastPollAt: Long) : GatewayStatus()
    data class Error(val message: String) : GatewayStatus()
}

object GatewayState {
    private val _status = MutableStateFlow<GatewayStatus>(GatewayStatus.Idle)
    val status: StateFlow<GatewayStatus> = _status

    fun update(status: GatewayStatus) {
        _status.value = status
    }

    fun reset() {
        _status.value = GatewayStatus.Idle
    }
}
