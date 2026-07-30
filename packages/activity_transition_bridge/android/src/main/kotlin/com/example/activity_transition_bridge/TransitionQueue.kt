package com.example.activity_transition_bridge

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

internal data class QueuedTransition(
    val id: String,
    val sessionId: String,
    val activityType: String,
    val transitionType: String,
    val eventElapsedRealtimeNanos: Long,
    val receivedElapsedRealtimeNanos: Long,
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("sessionId", sessionId)
        .put("activityType", activityType)
        .put("transitionType", transitionType)
        .put("eventElapsedRealtimeNanos", eventElapsedRealtimeNanos)
        .put("receivedElapsedRealtimeNanos", receivedElapsedRealtimeNanos)

    fun toMap(): Map<String, Any> = mapOf(
        "id" to id,
        "sessionId" to sessionId,
        "activityType" to activityType,
        "transitionType" to transitionType,
        "eventElapsedRealtimeNanos" to eventElapsedRealtimeNanos,
        "receivedElapsedRealtimeNanos" to receivedElapsedRealtimeNanos,
    )

    companion object {
        fun fromJson(value: JSONObject): QueuedTransition = QueuedTransition(
            id = value.getString("id"),
            sessionId = value.getString("sessionId"),
            activityType = value.getString("activityType"),
            transitionType = value.getString("transitionType"),
            eventElapsedRealtimeNanos = value.getLong("eventElapsedRealtimeNanos"),
            receivedElapsedRealtimeNanos = value.getLong("receivedElapsedRealtimeNanos"),
        )
    }
}

internal object TransitionQueue {
    private const val preferencesName = "walkapp_activity_transition_experiment"
    private const val queueKey = "transition_queue"
    private const val sessionKey = "active_session"
    private const val registeredKey = "registered"

    @Synchronized
    fun beginSession(context: Context, sessionId: String) {
        preferences(context).edit()
            .putString(sessionKey, sessionId)
            .putBoolean(registeredKey, true)
            .putString(queueKey, "[]")
            .commit()
    }

    @Synchronized
    fun endSession(context: Context, sessionId: String) {
        val preferences = preferences(context)
        if (preferences.getString(sessionKey, null) != sessionId) return
        preferences.edit()
            .remove(sessionKey)
            .putBoolean(registeredKey, false)
            .putString(queueKey, "[]")
            .commit()
    }

    @Synchronized
    fun activeSession(context: Context): String? {
        val preferences = preferences(context)
        if (!preferences.getBoolean(registeredKey, false)) return null
        return preferences.getString(sessionKey, null)
    }

    @Synchronized
    fun append(context: Context, event: QueuedTransition): Boolean {
        if (activeSession(context) != event.sessionId) return false
        val events = read(context).toMutableList()
        if (events.any { it.id == event.id }) return false
        events.add(event)
        events.sortWith(
            compareBy<QueuedTransition> { it.eventElapsedRealtimeNanos }
                .thenBy { it.id },
        )
        write(context, events)
        return true
    }

    @Synchronized
    fun peek(context: Context, sessionId: String): List<QueuedTransition> {
        if (activeSession(context) != sessionId) return emptyList()
        return read(context).filter { it.sessionId == sessionId }
    }

    @Synchronized
    fun acknowledge(context: Context, sessionId: String, ids: Set<String>) {
        if (activeSession(context) != sessionId || ids.isEmpty()) return
        write(
            context,
            read(context).filterNot { it.sessionId == sessionId && it.id in ids },
        )
    }

    @Synchronized
    fun clear(context: Context, sessionId: String) {
        if (activeSession(context) != sessionId) return
        write(context, read(context).filterNot { it.sessionId == sessionId })
    }

    private fun read(context: Context): List<QueuedTransition> {
        val raw = preferences(context).getString(queueKey, "[]") ?: "[]"
        return runCatching {
            val array = JSONArray(raw)
            buildList {
                for (index in 0 until array.length()) {
                    add(QueuedTransition.fromJson(array.getJSONObject(index)))
                }
            }
        }.getOrDefault(emptyList())
    }

    private fun write(context: Context, events: List<QueuedTransition>) {
        val array = JSONArray()
        events.forEach { array.put(it.toJson()) }
        preferences(context).edit().putString(queueKey, array.toString()).commit()
    }

    private fun preferences(context: Context) =
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
}
