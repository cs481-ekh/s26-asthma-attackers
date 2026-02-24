import '../widgets/symptom_modal.dart';

/// Arguments passed from home to recommendation page.
/// Either [location] (ZIP/city) or [latitude]/[longitude] (from geolocation) is used for AQI.
class RecommendationArgs {
  const RecommendationArgs({
    required this.symptomLevel,
    required this.location,
    this.latitude,
    this.longitude,
  });

  final SymptomLevel symptomLevel;
  /// Display label and fallback: ZIP/city string or "Current location" when using GPS.
  final String location;
  /// When set with [longitude], AQI is fetched by coordinates (e.g. AirNow by lat/long).
  final double? latitude;
  final double? longitude;

  bool get useCoordinates =>
      latitude != null && longitude != null;
}
