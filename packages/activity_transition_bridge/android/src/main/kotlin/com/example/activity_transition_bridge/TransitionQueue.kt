package com.example.activity_transition_bridge

import android.content.Context
import android.os.SystemClock
import org.json.JSONArray
import org.json.JSONObject

internal data class QueuedTransition(
    val id: String,
    val sessionId: String,
    val activityType: String,
    val transitionType: String,
    val eventElapsedRealtimeNanos: Long,
    val receivedElapsedRealtimeNanos: Long,
    val receiverEnteredElapsedRealtimeNanos: Long = receivedElapsedRealtimeNanos,
    val transitionResultParsedElapsedRealtimeNanos: Long? = null,
    val transitionQueuedElapsedRealtimeNanos: Long? = null,
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("sessionId", sessionId)
        .put("activityType", activityType)
        .put("transitionType", transitionType)
        .put("eventElapsedRealtimeNanos", eventElapsedRealtimeNanos)
        .put("receivedElapsedRealtimeNanos", receivedElapsedRealtimeNanos)
        .put("receiverEnteredElapsedRealtimeNanos", receiverEnteredElapsedRealtimeNanos)
        .put("transitionResultParsedElapsedRealtimeNanos", transitionResultParsedElapsedRealtimeNanos)
        .put("transitionQueuedElapsedRealtimeNanos", transitionQueuedElapsedRealtimeNanos)

    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "sessionId" to sessionId,
        "activityType" to activityType,
        "transitionType" to transitionType,
        "eventElapsedRealtimeNanos" to eventElapsedRealtimeNanos,
        "receivedElapsedRealtimeNanos" to receivedElapsedRealtimeNanos,
        "receiverEnteredElapsedRealtimeNanos" to receiverEnteredElapsedRealtimeNanos,
        "transitionResultParsedElapsedRealtimeNanos" to transitionResultParsedElapsedRealtimeNanos,
        "transitionQueuedElapsedRealtimeNanos" to transitionQueuedElapsedRealtimeNanos,
    )

    companion object {
        fun fromJson(value: JSONObject): QueuedTransition = QueuedTransition(
            id = value.getString("id"),
            sessionId = value.getString("sessionId"),
            activityType = value.getString("activityType"),
            transitionType = value.getString("transitionType"),
            eventElapsedRealtimeNanos = value.getLong("eventElapsedRealtimeNanos"),
            receivedElapsedRealtimeNanos = value.getLong("receivedElapsedRealtimeNanos"),
            receiverEnteredElapsedRealtimeNanos = value.optLong(
                "receiverEnteredElapsedRealtimeNanos",
                value.getLong("receivedElapsedRealtimeNanos"),
            ),
            transitionResultParsedElapsedRealtimeNanos = value.optNullableLong(
                "transitionResultParsedElapsedRealtimeNanos",
            ),
            transitionQueuedElapsedRealtimeNanos = value.optNullableLong(
                "transitionQueuedElapsedRealtimeNanos",
            ),
        )
    }
}

internal object TransitionQueue {
    private const val preferencesName = "walkapp_activity_transition_experiment"
    private const val queueKey = "transition_queue"
    private const val sessionKey = "active_session"
    private const val registeredKey = "registered"
    private const val diagnosticSessionKey = "diagnostic_session"
    private const val diagnosticDirectoryKey = "diagnostic_directory"

    @Synchronized
    fun beginSession(
        context: Context,
        sessionId: String,
        diagnosticSessionId: String?,
        diagnosticDirectoryPath: String?,
    ) {
        preferences(context).edit()
            .putString(sessionKey, sessionId)
            .putBoolean(registeredKey, true)
            .putString(queueKey, "[]")
            .putString(diagnosticSessionKey, diagnosticSessionId)
            .putString(diagnosticDirectoryKey, diagnosticDirectoryPath)
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
            .remove(diagnosticSessionKey)
            .remove(diagnosticDirectoryKey)
            .commit()
    }

    @Synchronized
    fun activeSession(context: Context): String? {
        val preferences = preferences(context)
        if (!preferences.getBoolean(registeredKey, false)) return null
        return preferences.getString(sessionKey, null)
    }

    fun diagnosticSession(context: Context): Pair<String, String>? {
        val preferences = preferences(context)
        val id = preferences.getString(diagnosticSessionKey, null) ?: return null
        val directory = preferences.getString(diagnosticDirectoryKey, null) ?: return null
        return id to directory
    }

    @Synchronized
    fun append(context: Context, event: QueuedTransition): Boolean {
        if (activeSession(context) != event.sessionId) return false
        val events = read(context).toMutableList()
        if (events.any { it.id == event.id }) return false
        events.add(
            event.copy(
                transitionQueuedElapsedRealtimeNanos =
                    SystemClock.elapsedRealtimeNanos(),
            ),
        )
        events.sortWith(
            compareBy<QueuedTransition> { it.eventElapsedRealtimeNanos }
                .thenBy { it.id },
        )
        return write(context, events)
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

    private fun write(context: Context, events: List<QueuedTransition>): Boolean {
        val array = JSONArray()
        events.forEach { array.put(it.toJson()) }
        return preferences(context).edit().putString(queueKey, array.toString()).commit()
    }

    private fun preferences(context: Context) =
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
}

private fun JSONObject.optNullableLong(key: String): Long? =
    if (has(key) && !isNull(key)) getLong(key) else null
