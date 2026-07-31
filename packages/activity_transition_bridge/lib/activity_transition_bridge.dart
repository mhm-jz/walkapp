import 'package:flutter/services.dart';

final class ActivityTransitionRegistration {
  const ActivityTransitionRegistration({
    required this.sessionId,
    required this.sessionStartElapsedRealtimeNanos,
  });

  final String sessionId;
  final int sessionStartElapsedRealtimeNanos;
}

final class NativeActivityTransitionEvent {
  const NativeActivityTransitionEvent({
    required this.id,
    required this.sessionId,
    required this.activityType,
    required this.transitionType,
    required this.eventElapsedRealtimeNanos,
    required this.receivedElapsedRealtimeNanos,
    required this.receiverEnteredElapsedRealtimeNanos,
    this.transitionResultParsedElapsedRealtimeNanos,
    this.transitionQueuedElapsedRealtimeNanos,
  });

  factory NativeActivityTransitionEvent.fromMap(Map<Object?, Object?> map) {
    return NativeActivityTransitionEvent(
      id: map['id']!.toString(),
      sessionId: map['sessionId']!.toString(),
      activityType: map['activityType']!.toString(),
      transitionType: map['transitionType']!.toString(),
      eventElapsedRealtimeNanos:
          (map['eventElapsedRealtimeNanos'] as num).toInt(),
      receivedElapsedRealtimeNanos:
          (map['receivedElapsedRealtimeNanos'] as num).toInt(),
      receiverEnteredElapsedRealtimeNanos:
          (map['receiverEnteredElapsedRealtimeNanos'] as num?)?.toInt() ??
          (map['receivedElapsedRealtimeNanos'] as num).toInt(),
      transitionResultParsedElapsedRealtimeNanos:
          (map['transitionResultParsedElapsedRealtimeNanos'] as num?)?.toInt(),
      transitionQueuedElapsedRealtimeNanos:
          (map['transitionQueuedElapsedRealtimeNanos'] as num?)?.toInt(),
    );
  }

  final String id;
  final String sessionId;
  final String activityType;
  final String transitionType;
  final int eventElapsedRealtimeNanos;
  final int receivedElapsedRealtimeNanos;
  final int receiverEnteredElapsedRealtimeNanos;
  final int? transitionResultParsedElapsedRealtimeNanos;
  final int? transitionQueuedElapsedRealtimeNanos;
}

final class ActivityTransitionBridge {
  ActivityTransitionBridge._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.walkingapp/activity_transitions',
  );

  static Future<String> requestActivityRecognitionPermission() async {
    return await _channel.invokeMethod<String>('requestPermission') ??
        'denied';
  }

  static Future<int?> elapsedRealtimeNanos() async =>
      await _channel.invokeMethod<int>('elapsedRealtimeNanos');

  static Future<ActivityTransitionRegistration> register({
    required String sessionId,
    String? diagnosticSessionId,
    String? diagnosticDirectoryPath,
  }) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'register',
      <String, Object?>{
        'sessionId': sessionId,
        'diagnosticSessionId': diagnosticSessionId,
        'diagnosticDirectoryPath': diagnosticDirectoryPath,
      },
    );
    if (result == null) {
      throw StateError('Activity Transition registration returned no result.');
    }
    return ActivityTransitionRegistration(
      sessionId: result['sessionId']!.toString(),
      sessionStartElapsedRealtimeNanos:
          (result['sessionStartElapsedRealtimeNanos'] as num).toInt(),
    );
  }

  static Future<void> unregister({required String sessionId}) {
    return _channel.invokeMethod<void>(
      'unregister',
      <String, Object?>{'sessionId': sessionId},
    );
  }

  static Future<List<NativeActivityTransitionEvent>> peek({
    required String sessionId,
  }) async {
    final values = await _channel.invokeListMethod<Object?>(
      'peek',
      <String, Object?>{'sessionId': sessionId},
    );
    if (values == null) return const <NativeActivityTransitionEvent>[];
    return values
        .whereType<Map<Object?, Object?>>()
        .map(NativeActivityTransitionEvent.fromMap)
        .toList(growable: false);
  }

  static Future<void> acknowledge({
    required String sessionId,
    required Iterable<String> eventIds,
  }) {
    return _channel.invokeMethod<void>(
      'acknowledge',
      <String, Object?>{
        'sessionId': sessionId,
        'eventIds': eventIds.toList(growable: false),
      },
    );
  }

  static Future<void> clear({required String sessionId}) {
    return _channel.invokeMethod<void>(
      'clear',
      <String, Object?>{'sessionId': sessionId},
    );
  }

  static Future<List<String>> peekReceiverDiagnostics({
    required String diagnosticSessionId,
  }) async =>
      await _channel.invokeListMethod<String>(
        'peekReceiverDiagnostics',
        <String, Object?>{'diagnosticSessionId': diagnosticSessionId},
      ) ??
      const <String>[];

  static Future<bool> acknowledgeReceiverDiagnostics({
    required String diagnosticSessionId,
    required Iterable<String> diagnosticIds,
  }) async =>
      await _channel.invokeMethod<bool>(
        'acknowledgeReceiverDiagnostics',
        <String, Object?>{
          'diagnosticSessionId': diagnosticSessionId,
          'diagnosticIds': diagnosticIds.toList(growable: false),
        },
      ) ??
      false;
}
