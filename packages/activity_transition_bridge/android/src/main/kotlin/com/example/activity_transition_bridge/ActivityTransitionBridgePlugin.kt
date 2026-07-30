package com.example.activity_transition_bridge

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.SystemClock
import android.util.Log
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionRequest
import com.google.android.gms.location.DetectedActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ActivityTransitionBridgePlugin :
    FlutterPlugin,
    ActivityAware,
    MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var permissionResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(
            binding.binaryMessenger,
            "com.example.walkingapp/activity_transitions",
        )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermission" -> requestPermission(result)
            "register" -> register(requireSessionId(call), result)
            "unregister" -> unregister(requireSessionId(call), result)
            "peek" -> {
                val events = TransitionQueue.peek(context, requireSessionId(call))
                result.success(events.map { it.toMap() })
            }
            "acknowledge" -> {
                val ids = call.argument<List<String>>("eventIds")?.toSet().orEmpty()
                TransitionQueue.acknowledge(context, requireSessionId(call), ids)
                result.success(null)
            }
            "clear" -> {
                TransitionQueue.clear(context, requireSessionId(call))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun register(sessionId: String, result: MethodChannel.Result) {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            context.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            result.error("permission_denied", "Activity Recognition permission is required.", null)
            return
        }

        TransitionQueue.beginSession(context, sessionId)
        removeStaleRegistration(sessionId) {
            registerFreshPendingIntent(sessionId, result)
        }
    }

    private fun removeStaleRegistration(sessionId: String, onComplete: () -> Unit) {
        val oldPendingIntent = immutablePendingIntent(PendingIntent.FLAG_NO_CREATE)
        if (oldPendingIntent == null) {
            Log.i(
                "WalkAppTransition",
                "[STEP_TRANSITION_OLD_REGISTRATION_REMOVED] status=not_found " +
                    registrationMetadata(sessionId, "IMMUTABLE"),
            )
            onComplete()
            return
        }

        ActivityRecognition.getClient(context)
            .removeActivityTransitionUpdates(oldPendingIntent)
            .addOnCompleteListener { task ->
                oldPendingIntent.cancel()
                Log.i(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_OLD_REGISTRATION_REMOVED] " +
                        "status=${if (task.isSuccessful) "success" else "best_effort_failure"} " +
                        registrationMetadata(sessionId, "IMMUTABLE") +
                        safeFailureType(task.exception),
                )
                onComplete()
            }
    }

    private fun registerFreshPendingIntent(
        sessionId: String,
        result: MethodChannel.Result,
    ) {
        val pendingIntent = callbackPendingIntent()
        val mutability = callbackMutability()
        Log.i(
            "WalkAppTransition",
            "[STEP_TRANSITION_PENDING_INTENT_CREATED] " +
                registrationMetadata(sessionId, mutability),
        )
        Log.i(
            "WalkAppTransition",
            "[STEP_TRANSITION_REGISTER_REQUEST] " +
                registrationMetadata(sessionId, mutability),
        )

        ActivityRecognition.getClient(context)
            .requestActivityTransitionUpdates(request(), pendingIntent)
            .addOnSuccessListener {
                val now = SystemClock.elapsedRealtimeNanos()
                Log.i(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_REGISTER_SUCCESS] " +
                        registrationMetadata(sessionId, mutability) +
                        "eventElapsedMs=${now / 1_000_000} " +
                        "receivedElapsedMs=${now / 1_000_000} deliveryDelayMs=0",
                )
                Log.i(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_REGISTER] activity=ALL transition=ENTER_EXIT " +
                        "eventElapsedMs=${now / 1_000_000} receivedElapsedMs=${now / 1_000_000} " +
                        "deliveryDelayMs=0 sessionId=$sessionId",
                )
                result.success(
                    mapOf(
                        "sessionId" to sessionId,
                        "sessionStartElapsedRealtimeNanos" to now,
                    ),
                )
            }
            .addOnFailureListener { error ->
                TransitionQueue.endSession(context, sessionId)
                Log.e(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_REGISTER_FAILURE] " +
                        registrationMetadata(sessionId, mutability) +
                        "failureType=${error.javaClass.simpleName}",
                )
                result.error(
                    "registration_failed",
                    error.message ?: "Activity Transition registration failed.",
                    null,
                )
            }
    }

    private fun requestPermission(result: MethodChannel.Result) {
        if (
            Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            context.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
                PackageManager.PERMISSION_GRANTED
        ) {
            result.success("granted")
            return
        }
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("activity_unavailable", "Permission UI is unavailable.", null)
            return
        }
        if (permissionResult != null) {
            result.error("request_in_progress", "Permission request is already active.", null)
            return
        }
        permissionResult = result
        currentActivity.requestPermissions(
            arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
            permissionRequestCode,
        )
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(::onRequestPermissionsResult)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    private fun detachActivity() {
        activityBinding?.removeRequestPermissionsResultListener(::onRequestPermissionsResult)
        activityBinding = null
        activity = null
        permissionResult?.error(
            "activity_unavailable",
            "Permission UI was detached.",
            null,
        )
        permissionResult = null
    }

    private fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != permissionRequestCode) return false
        val result = permissionResult ?: return false
        permissionResult = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
        } else {
            val permanentlyDenied =
                activity?.shouldShowRequestPermissionRationale(
                    Manifest.permission.ACTIVITY_RECOGNITION,
                ) == false
            result.success(if (permanentlyDenied) "permanentlyDenied" else "denied")
        }
        return true
    }

    private fun unregister(sessionId: String, result: MethodChannel.Result) {
        ActivityRecognition.getClient(context)
            .removeActivityTransitionUpdates(callbackPendingIntent())
            .addOnCompleteListener { task ->
                TransitionQueue.endSession(context, sessionId)
                val now = SystemClock.elapsedRealtimeNanos()
                Log.i(
                    "WalkAppTransition",
                    "[STEP_TRANSITION_UNREGISTER] activity=ALL transition=ENTER_EXIT " +
                        "eventElapsedMs=${now / 1_000_000} receivedElapsedMs=${now / 1_000_000} " +
                        "deliveryDelayMs=0 sessionId=$sessionId success=${task.isSuccessful}",
                )
                result.success(null)
            }
    }

    private fun request(): ActivityTransitionRequest {
        val transitions = buildList {
            val activities = listOf(
                DetectedActivity.WALKING,
                DetectedActivity.RUNNING,
                DetectedActivity.STILL,
                DetectedActivity.ON_BICYCLE,
                DetectedActivity.IN_VEHICLE,
            )
            activities.forEach { activity ->
                add(
                    ActivityTransition.Builder()
                        .setActivityType(activity)
                        .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                        .build(),
                )
                add(
                    ActivityTransition.Builder()
                        .setActivityType(activity)
                        .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                        .build(),
                )
            }
        }
        return ActivityTransitionRequest(transitions)
    }

    private fun callbackPendingIntent(): PendingIntent {
        val intent = Intent(context, ActivityTransitionReceiver::class.java)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE
            } else {
                0
            }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            flags,
        )
    }

    private fun immutablePendingIntent(additionalFlags: Int): PendingIntent? {
        val intent = Intent(context, ActivityTransitionReceiver::class.java)
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or additionalFlags,
        )
    }

    private fun callbackMutability(): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) "MUTABLE" else "LEGACY"

    private fun registrationMetadata(sessionId: String, mutability: String): String =
        "sdk=${Build.VERSION.SDK_INT} mutability=$mutability requestCode=$requestCode " +
            "receiver=${ActivityTransitionReceiver::class.java.name} explicit=true " +
            "transitions=$registeredTransitions sessionId=$sessionId "

    private fun safeFailureType(error: Exception?): String =
        if (error == null) "" else " failureType=${error.javaClass.simpleName}"

    private fun requireSessionId(call: MethodCall): String {
        return requireNotNull(call.argument<String>("sessionId")) {
            "sessionId is required"
        }
    }

    private companion object {
        const val requestCode = 41027
        const val permissionRequestCode = 41028
        const val registeredTransitions =
            "WALKING:ENTER_EXIT,RUNNING:ENTER_EXIT,STILL:ENTER_EXIT," +
                "ON_BICYCLE:ENTER_EXIT,IN_VEHICLE:ENTER_EXIT"
    }
}
