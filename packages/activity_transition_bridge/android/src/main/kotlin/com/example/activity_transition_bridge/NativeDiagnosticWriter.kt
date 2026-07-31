package com.example.activity_transition_bridge

import android.content.Context
import android.os.Process
import android.os.SystemClock
import android.util.Log
import org.json.JSONObject
import java.io.File
import java.time.Instant
import java.util.UUID

internal object NativeDiagnosticWriter {
    private const val preferencesName = "walkapp_native_step_diagnostics"

    @Synchronized
    fun record(
        context: Context,
        eventType: String,
        receiverInvocationId: String,
        receiverEnteredElapsedRealtimeMs: Long,
        receiverEnteredWallClockUtc: String,
        sessionIdAtReceive: String?,
        payload: JSONObject = JSONObject(),
    ): Boolean {
        return runCatching {
            val diagnostic = TransitionQueue.diagnosticSession(context)
            val diagnosticSessionId = diagnostic?.first
            val directory = File(
                diagnostic?.second ?: File(context.filesDir, "diagnostics").path,
            ).apply { mkdirs() }
            val fileIdentity = diagnosticSessionId ?: "unassociated"
            val preferences = context.getSharedPreferences(
                preferencesName,
                Context.MODE_PRIVATE,
            )
            val sequenceKey = "sequence_$fileIdentity"
            val sequence = preferences.getLong(sequenceKey, 0L) + 1L
            val recordedElapsedMs = SystemClock.elapsedRealtime()
            val recordedWallClockUtc = Instant.now().toString()
            val diagnosticId =
                "$receiverInvocationId-$sequence-$eventType-${UUID.randomUUID().toString().take(8)}"
            payload
                .put("receiverInvocationId", receiverInvocationId)
                .put("diagnosticSchemaVersion", 2)
                .put("applicationId", context.packageName)
                .put("applicationVersion", "1.0.0+1")
                .put("sessionIdAtReceive", sessionIdAtReceive)
                .put("nativeProcessId", Process.myPid())
                .put("threadName", Thread.currentThread().name)
                .put("receiverEnteredElapsedRealtimeMs", receiverEnteredElapsedRealtimeMs)
                .put("receiverEnteredWallClockUtc", receiverEnteredWallClockUtc)
            val event = JSONObject()
                .put("schemaVersion", 2)
                .put("diagnosticId", diagnosticId)
                .put("sessionId", diagnosticSessionId ?: JSONObject.NULL)
                .put("validationMode", "transition")
                .put("applicationId", context.packageName)
                .put("applicationVersion", "1.0.0+1")
                .put("eventType", eventType)
                .put("sequenceNumber", sequence)
                .put("source", "native-receiver")
                .put("wallClockUtc", recordedWallClockUtc)
                .put("recordedAtWallClockUtc", recordedWallClockUtc)
                .put("elapsedRealtimeMs", recordedElapsedMs)
                .put("recordedAtElapsedRealtimeMs", recordedElapsedMs)
                .put("payload", payload)
            File(directory, "$fileIdentity-native-receiver.jsonl")
                .appendText(event.toString() + "\n")
            preferences.edit().putLong(sequenceKey, sequence).commit()
            true
        }.getOrElse { error ->
            Log.e(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_DIAGNOSTIC_WRITE_FAILURE] " +
                    "eventType=$eventType failureType=${error.javaClass.simpleName}",
            )
            false
        }
    }

    @Synchronized
    fun peek(context: Context, diagnosticSessionId: String): List<String> {
        val diagnostic = TransitionQueue.diagnosticSession(context) ?: return emptyList()
        if (diagnostic.first != diagnosticSessionId) return emptyList()
        val file = File(
            diagnostic.second,
            "$diagnosticSessionId-native-receiver.jsonl",
        )
        if (!file.exists()) return emptyList()
        return runCatching { file.readLines().filter { it.isNotBlank() } }
            .getOrDefault(emptyList())
    }

    @Synchronized
    fun acknowledge(
        context: Context,
        diagnosticSessionId: String,
        diagnosticIds: Set<String>,
    ): Boolean {
        if (diagnosticIds.isEmpty()) return true
        val diagnostic = TransitionQueue.diagnosticSession(context) ?: return false
        if (diagnostic.first != diagnosticSessionId) return false
        val file = File(
            diagnostic.second,
            "$diagnosticSessionId-native-receiver.jsonl",
        )
        if (!file.exists()) return true
        return runCatching {
            val retained = file.readLines().filter { line ->
                val id = runCatching { JSONObject(line).optString("diagnosticId") }
                    .getOrNull()
                id == null || id !in diagnosticIds
            }
            file.writeText(
                if (retained.isEmpty()) "" else retained.joinToString("\n", postfix = "\n"),
            )
            true
        }.getOrDefault(false)
    }
}
