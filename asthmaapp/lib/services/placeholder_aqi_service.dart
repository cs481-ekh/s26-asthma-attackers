import 'dart:async';

import '../models/aqi_result.dart';
import 'aqi_service.dart';

/// Placeholder implementation: no real API calls.
/// Replace with EPA AirNow (by ZIP or by latitude/longitude).
class PlaceholderAqiService implements AqiService {
  PlaceholderAqiService({this.simulateFailure = false});

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
    return AqiSuccess(
      data: AqiData(
        aqiValue: 42,
        category: 'Good',
        locationLabel: locationInput.trim(),
      ),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<AqiResult> getAqiForCoordinates(double latitude, double longitude) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (simulateFailure) {
      return const AqiFailure(
        message: 'Unable to load air quality data. Check your connection and try again.',
        lastKnown: null,
      );
    }
    return AqiSuccess(
      data: AqiData(
        aqiValue: 38,
        category: 'Good',
        locationLabel: 'Current location',
      ),
      lastUpdated: DateTime.now(),
    );
  }
}
