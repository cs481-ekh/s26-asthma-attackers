import 'dart:async';

import '../models/aqi_result.dart';
import 'aqi_service.dart';

/// Placeholder implementation: no real API calls.
/// Replace with EPA AirNow integration (CurrentObservationsByZip/query).
class PlaceholderAqiService implements AqiService {
  PlaceholderAqiService({this.simulateFailure = false});

  /// Set true to test failed-API UI (e.g. in tests or debug).
  final bool simulateFailure;

  @override
  Future<AqiResult> getAqiForLocation(String locationInput) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (simulateFailure) {
      return const AqiFailure(
        message: 'Unable to load air quality data. Check your connection and try again.',
        lastKnown: null,
      );
    }
    if (locationInput.trim().isEmpty) {
      return const AqiFailure(
        message: 'Please enter a ZIP code or city on the home screen.',
      );
    }
    // Stub data for UI development. Replace with real API response parsing.
    return AqiSuccess(
      data: AqiData(
        aqiValue: 42,
        category: 'Good',
        locationLabel: locationInput.trim(),
      ),
      lastUpdated: DateTime.now(),
    );
  }
}
