import '../../../l10n/app_localizations.dart';
import '../domain/tracking_activity.dart';

extension TrackingActivityLocalization on TrackingActivity {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      TrackingActivity.walking => l10n.walking,
      TrackingActivity.running => l10n.running,
      TrackingActivity.still => l10n.still,
      TrackingActivity.inVehicle => l10n.inVehicle,
      TrackingActivity.onBicycle => l10n.cycling,
      TrackingActivity.unknown => l10n.unknown,
    };
  }
}
