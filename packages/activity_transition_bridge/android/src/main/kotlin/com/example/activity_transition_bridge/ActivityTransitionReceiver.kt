package com.example.activity_transition_bridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.DetectedActivity

class ActivityTransitionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val receivedNanos = SystemClock.elapsedRealtimeNanos()
        val sessionId = TransitionQueue.activeSession(context)
        val extraKeys = runCatching {
            intent?.extras?.keySet()?.sorted()?.joinToString(",")
        }.getOrNull()
        val extrasNull = runCatching { intent?.extras == null }.getOrDefault(true)
        val hasResult = if (intent == null) {
            false
        } else {
            runCatching { ActivityTransitionResult.hasResult(intent) }
                .getOrElse { error ->
                    logError(
                        "has_result",
                        error,
                        receivedNanos,
                        sessionId,
                    )
                    false
                }
        }
        Log.i(
            "WalkAppTransition",
            "[STEP_TRANSITION_RECEIVER_ENTER] action=${intent?.action ?: "none"} " +
                "component=${intent?.component?.flattenToShortString() ?: "none"} " +
                "extrasNull=$extrasNull extraKeys=${extraKeys ?: "none"} " +
                "hasResult=$hasResult receivedElapsedMs=${receivedNanos / 1_000_000} " +
                "sessionId=${sessionId ?: "none"}",
        )

        if (intent == null) {
            Log.w(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_NULL_INTENT] " +
                    "receivedElapsedMs=${receivedNanos / 1_000_000} " +
                    "sessionId=${sessionId ?: "none"}",
            )
            return
        }
        if (!hasResult) {
            Log.w(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_NO_RESULT] " +
                    "receivedElapsedMs=${receivedNanos / 1_000_000} " +
                    "sessionId=${sessionId ?: "none"}",
            )
            return
        }
        if (sessionId == null) {
            Log.w(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_ERROR] stage=active_session " +
                    "failureType=MissingActiveSession " +
                    "receivedElapsedMs=${receivedNanos / 1_000_000} sessionId=none",
            )
            return
        }
        val result = runCatching {
            ActivityTransitionResult.extractResult(intent)
        }.getOrElse { error ->
            logError("extract_result", error, receivedNanos, sessionId)
            return
        }
        if (result == null) {
            Log.w(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_ERROR] stage=extract_result " +
                    "failureType=NullResult receivedElapsedMs=${receivedNanos / 1_000_000} " +
                    "sessionId=$sessionId",
            )
            return
        }
        val events = result.transitionEvents.sortedBy { it.elapsedRealTimeNanos }
        Log.i(
            "WalkAppTransition",
            "[STEP_TRANSITION_RECEIVER_RESULT] eventCount=${events.size} " +
                "receivedElapsedMs=${receivedNanos / 1_000_000} sessionId=$sessionId",
        )
        if (events.isEmpty()) return

        events.forEach { event ->
            val activity = activityName(event.activityType)
            val transition = transitionName(event.transitionType)
            if (activity == null || transition == null) {
                Log.w(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_RECEIVER_ERROR] stage=map_event " +
                        "failureType=UnsupportedTransitionEvent " +
                        "receivedElapsedMs=${receivedNanos / 1_000_000} " +
                        "sessionId=$sessionId",
                )
                return@forEach
            }
            val id = "$sessionId:$activity:$transition:${event.elapsedRealTimeNanos}"
            Log.i(
                "WalkAppTransition",
                "[STEP_TRANSITION_RECEIVER_EVENT] activity=$activity " +
                    "transition=$transition " +
                    "eventElapsedMs=${event.elapsedRealTimeNanos / 1_000_000} " +
                    "receivedElapsedMs=${receivedNanos / 1_000_000} " +
                    "sessionId=$sessionId deduplicationKey=$id",
            )
            val queued = QueuedTransition(
                id = id,
                sessionId = sessionId,
                activityType = activity,
                transitionType = transition,
                eventElapsedRealtimeNanos = event.elapsedRealTimeNanos,
                receivedElapsedRealtimeNanos = receivedNanos,
            )
            val added = TransitionQueue.append(context, queued)
            val delayMs = (receivedNanos - event.elapsedRealTimeNanos) / 1_000_000
            Log.i(
                "WalkAppTransition",
                "[STEP_TRANSITION_${if (added) "RECEIVE" else "DUPLICATE"}] " +
                    "activity=$activity transition=$transition " +
                    "eventElapsedMs=${event.elapsedRealTimeNanos / 1_000_000} " +
                    "receivedElapsedMs=${receivedNanos / 1_000_000} " +
                    "deliveryDelayMs=$delayMs sessionId=$sessionId",
            )
        }
    }

    private fun logError(
        stage: String,
        error: Throwable,
        receivedNanos: Long,
        sessionId: String?,
    ) {
        Log.e(
            "WalkAppTransition",
            "[STEP_TRANSITION_RECEIVER_ERROR] stage=$stage " +
                "failureType=${error.javaClass.simpleName} " +
                "receivedElapsedMs=${receivedNanos / 1_000_000} " +
                "sessionId=${sessionId ?: "none"}",
        )
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
