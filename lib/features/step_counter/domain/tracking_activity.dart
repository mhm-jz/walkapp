enum TrackingActivity {
  walking,
  running,
  inVehicle,
  onBicycle,
  still,
  unknown;

  String get storageName => switch (this) {
    walking => 'WALKING',
    running => 'RUNNING',
    inVehicle => 'IN_VEHICLE',
    onBicycle => 'ON_BICYCLE',
    still => 'STILL',
    unknown => 'UNKNOWN',
  };

  static TrackingActivity fromStorage(Object? value) {
    return switch (value?.toString()) {
      'WALKING' => walking,
      'RUNNING' => running,
      'IN_VEHICLE' => inVehicle,
      'ON_BICYCLE' => onBicycle,
      'STILL' => still,
      _ => unknown,
    };
  }
}

enum TrackingConfidence {
  low,
  medium,
  high;

  String get storageName => name.toUpperCase();

  static TrackingConfidence fromStorage(Object? value) {
    return switch (value?.toString()) {
      'HIGH' => high,
      'MEDIUM' => medium,
      _ => low,
    };
  }
}
