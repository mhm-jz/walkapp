package com.example.activity_transition_bridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.DetectedActivity
import org.json.JSONArray
import org.json.JSONObject
import java.time.Instant
import java.util.UUID

class ActivityTransitionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val enteredNanos = SystemClock.elapsedRealtimeNanos()
        val enteredMs = enteredNanos / 1_000_000
        val enteredUtc = Instant.now().toString()
        val invocationId = "receiver-$enteredMs-${UUID.randomUUID().toString().take(4)}"
        val sessionId = TransitionQueue.activeSession(context)
        val extrasKeys = runCatching { intent?.extras?.keySet()?.sorted().orEmpty() }
            .getOrDefault(emptyList())
        val base = JSONObject()
            .put("intentWasNull", intent == null)
            .put("intentAction", intent?.action)
            .put("intentComponent", intent?.component?.flattenToShortString())
            .put("intentFlags", intent?.flags)
            .put("extrasKeys", JSONArray(extrasKeys))

        fun persist(eventType: String, details: JSONObject = JSONObject()) =
            NativeDiagnosticWriter.record(
                context,
                eventType,
                invocationId,
                enteredMs,
                enteredUtc,
                sessionId,
                merge(base, details),
            )

        persist("TRANSITION_RECEIVER_ENTER")
        Log.i(
            "WalkAppTransition",
            "[STEP_TRANSITION_RECEIVER_ENTER] receiverInvocationId=$invocationId " +
                "action=${intent?.action ?: "none"} extrasKeys=${extrasKeys.joinToString(",")} " +
                "receivedElapsedMs=$enteredMs sessionId=${sessionId ?: "none"}",
        )

        try {
            if (intent == null) {
                persist("TRANSITION_RECEIVER_NULL_INTENT")
                Log.w(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_RECEIVER_NULL_INTENT] " +
                        "receiverInvocationId=$invocationId receivedElapsedMs=$enteredMs",
                )
                return
            }

            val checkedMs = SystemClock.elapsedRealtime()
            val hasResult = runCatching { ActivityTransitionResult.hasResult(intent) }
                .getOrElse { error ->
                    persistError("result_check", error, invocationId, checkedMs, ::persist)
                    return
                }
            persist(
                "TRANSITION_RECEIVER_RESULT_CHECK",
                JSONObject()
                    .put("resultCheckedElapsedRealtimeMs", checkedMs)
                    .put("hasActivityTransitionResult", hasResult),
            )
            if (!hasResult) {
                persist(
                    "TRANSITION_RECEIVER_NO_RESULT",
                    JSONObject()
                        .put("resultCheckedElapsedRealtimeMs", checkedMs)
                        .put("hasActivityTransitionResult", false),
                )
                Log.w(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_RECEIVER_NO_RESULT] " +
                        "receiverInvocationId=$invocationId receivedElapsedMs=$enteredMs " +
                        "sessionId=${sessionId ?: "none"}",
                )
                return
            }

            val result = runCatching { ActivityTransitionResult.extractResult(intent) }
                .getOrElse { error ->
                    persistError("result_parse", error, invocationId, SystemClock.elapsedRealtime(), ::persist)
                    return
                }
            val parsedMs = SystemClock.elapsedRealtime()
            if (result == null) {
                persistError(
                    "result_parse",
                    IllegalStateException("Null ActivityTransitionResult"),
                    invocationId,
                    parsedMs,
                    ::persist,
                )
                return
            }
            persist(
                "TRANSITION_RECEIVER_RESULT_PARSED",
                JSONObject()
                    .put("resultCheckedElapsedRealtimeMs", checkedMs)
                    .put("resultParsedElapsedRealtimeMs", parsedMs)
                    .put("hasActivityTransitionResult", true),
            )
            val events = result.transitionEvents.sortedBy { it.elapsedRealTimeNanos }
            persist(
                "TRANSITION_RECEIVER_EVENT_COUNT",
                JSONObject()
                    .put("resultParsedElapsedRealtimeMs", parsedMs)
                    .put("transitionEventCount", events.size),
            )
            Log.i(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_RESULT] receiverInvocationId=$invocationId " +
                    "eventCount=${events.size} receivedElapsedMs=$enteredMs " +
                    "sessionId=${sessionId ?: "none"}",
            )
            if (events.isEmpty()) return
            if (sessionId == null) {
                persistError(
                    "active_session",
                    IllegalStateException("Missing active session"),
                    invocationId,
                    SystemClock.elapsedRealtime(),
                    ::persist,
                )
                return
            }

            events.forEachIndexed { index, event ->
                val activity = activityName(event.activityType)
                val transition = transitionName(event.transitionType)
                if (activity == null || transition == null) {
                    persistError(
                        "event_parse",
                        IllegalArgumentException("Unsupported transition event"),
                        invocationId,
                        SystemClock.elapsedRealtime(),
                        ::persist,
                    )
                    return@forEachIndexed
                }
                val id = "$sessionId:$activity:$transition:${event.elapsedRealTimeNanos}"
                val eventMs = event.elapsedRealTimeNanos / 1_000_000
                persist(
                    "TRANSITION_RECEIVER_EVENT_PARSED",
                    JSONObject()
                        .put("transitionEventIndex", index)
                        .put("transitionEventCount", events.size)
                        .put("activityType", activity)
                        .put("transitionType", transition)
                        .put("transitionEventElapsedRealtimeNanos", event.elapsedRealTimeNanos)
                        .put("transitionEventElapsedRealtimeMs", eventMs)
                        .put("transitionResultParsedElapsedRealtimeMs", parsedMs)
                        .put("deduplicationKey", id),
                )
                Log.i(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_RECEIVER_EVENT] receiverInvocationId=$invocationId " +
                        "activity=$activity transition=$transition eventElapsedMs=$eventMs " +
                        "receivedElapsedMs=$enteredMs sessionId=$sessionId deduplicationKey=$id",
                )

                val attemptMs = SystemClock.elapsedRealtime()
                persist(
                    "TRANSITION_RECEIVER_QUEUE_ATTEMPT",
                    eventDetails(index, events.size, activity, transition, event.elapsedRealTimeNanos, parsedMs, attemptMs, id),
                )
                val added = runCatching {
                    TransitionQueue.append(
                        context,
                        QueuedTransition(
                            id = id,
                            sessionId = sessionId,
                            activityType = activity,
                            transitionType = transition,
                            eventElapsedRealtimeNanos = event.elapsedRealTimeNanos,
                            receivedElapsedRealtimeNanos = enteredNanos,
                            receiverEnteredElapsedRealtimeNanos = enteredNanos,
                            transitionResultParsedElapsedRealtimeNanos = parsedMs * 1_000_000,
                            transitionQueuedElapsedRealtimeNanos = null,
                        ),
                    )
                }.getOrElse { error ->
                    persistError("queue", error, invocationId, SystemClock.elapsedRealtime(), ::persist)
                    false
                }
                val completedMs = SystemClock.elapsedRealtime()
                val queuePayload = eventDetails(
                    index,
                    events.size,
                    activity,
                    transition,
                    event.elapsedRealTimeNanos,
                    parsedMs,
                    attemptMs,
                    id,
                )
                    .put("queueCompletedElapsedRealtimeMs", completedMs)
                    .put("transitionQueuedElapsedRealtimeMs", completedMs)
                    .put("queueDurationMs", completedMs - attemptMs)
                    .put("transitionDeliveryDelayMs", enteredMs - eventMs)
                    .put("receiverParsingDelayMs", parsedMs - enteredMs)
                    .put("nativeQueueDelayMs", completedMs - parsedMs)
                    .put(
                        "timingInvariantPassed",
                        eventMs <= enteredMs &&
                            enteredMs <= parsedMs &&
                            parsedMs <= completedMs,
                    )
                    .put(
                        "timingInvariantFailures",
                        JSONArray().apply {
                            if (eventMs > enteredMs) {
                                put("transitionEventElapsedRealtimeMs<=receiverEnteredElapsedRealtimeMs")
                            }
                            if (enteredMs > parsedMs) {
                                put("receiverEnteredElapsedRealtimeMs<=transitionResultParsedElapsedRealtimeMs")
                            }
                            if (parsedMs > completedMs) {
                                put("transitionResultParsedElapsedRealtimeMs<=transitionQueuedElapsedRealtimeMs")
                            }
                        },
                    )
                if (added) {
                    persist("TRANSITION_RECEIVER_QUEUE_SUCCESS", queuePayload)
                    Log.i(
                        "WalkAppTransition",
                        "[STEP_TRANSITION_RECEIVER_QUEUE_SUCCESS] " +
                            "receiverInvocationId=$invocationId deduplicationKey=$id",
                    )
                } else {
                    persist(
                        "TRANSITION_RECEIVER_QUEUE_FAILURE",
                        queuePayload.put("errorType", "NotQueuedOrDuplicate"),
                    )
                    Log.w(
                        "WalkAppTransition",
                        "[STEP_TRANSITION_RECEIVER_QUEUE_FAILURE] " +
                            "receiverInvocationId=$invocationId deduplicationKey=$id",
                    )
                }
            }
        } catch (error: Throwable) {
            persistError("receiver", error, invocationId, SystemClock.elapsedRealtime(), ::persist)
        } finally {
            persist(
                "TRANSITION_RECEIVER_EXIT",
                JSONObject().put("receiverExitElapsedRealtimeMs", SystemClock.elapsedRealtime()),
            )
        }
    }

    private fun persistError(
        stage: String,
        error: Throwable,
        invocationId: String,
        elapsedMs: Long,
        persist: (String, JSONObject) -> Boolean,
    ) {
        val safeMessage = "Native receiver $stage failure"
        persist(
            "TRANSITION_RECEIVER_ERROR",
            JSONObject()
                .put("errorStage", stage)
                .put("errorElapsedRealtimeMs", elapsedMs)
                .put("errorType", error.javaClass.simpleName)
                .put("sanitizedErrorMessage", safeMessage),
        )
        Log.e(
            "WalkAppTransition",
            "[STEP_TRANSITION_RECEIVER_ERROR] receiverInvocationId=$invocationId " +
                "stage=$stage failureType=${error.javaClass.simpleName}",
        )
    }

    private fun eventDetails(
        index: Int,
        count: Int,
        activity: String,
        transition: String,
        eventNanos: Long,
        parsedMs: Long,
        attemptMs: Long,
        id: String,
    ) = JSONObject()
        .put("transitionEventIndex", index)
        .put("transitionEventCount", count)
        .put("activityType", activity)
        .put("transitionType", transition)
        .put("transitionEventElapsedRealtimeNanos", eventNanos)
        .put("transitionEventElapsedRealtimeMs", eventNanos / 1_000_000)
        .put("transitionResultParsedElapsedRealtimeMs", parsedMs)
        .put("queueAttemptElapsedRealtimeMs", attemptMs)
        .put("deduplicationKey", id)

    private fun merge(left: JSONObject, right: JSONObject): JSONObject =
        JSONObject(left.toString()).also { merged ->
            right.keys().forEach { key -> merged.put(key, right.opt(key)) }
        }

    private fun activityName(type: Int): String? = when (type) {
        DetectedActivity.WALKING -> "WALKING"
        DetectedActivity.RUNNING -> "RUNNING"
        DetectedActivity.STILL -> "STILL"
        DetectedActivity.ON_BICYCLE -> "ON_BICYCLE"
        DetectedActivity.IN_VEHICLE -> "IN_VEHICLE"
        else -> null
    }

    private fun transitionName(type: Int): String? = when (type) {
        ActivityTransition.ACTIVITY_TRANSITION_ENTER -> "ENTER"
        ActivityTransition.ACTIVITY_TRANSITION_EXIT -> "EXIT"
        else -> null
    }
}
