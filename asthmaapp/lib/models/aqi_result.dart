/// Result of an AQI fetch: success with data or failure with message.
/// Supports "last-known AQI" for when the API is unavailable (project plan 2.4).
sealed class AqiResult {
  const AqiResult();
}

/// Successful AQI data from the API (or placeholder).
class AqiSuccess extends AqiResult {
  const AqiSuccess({
    required this.data,
    this.lastUpdated,
  });

  final AqiData data;
  final DateTime? lastUpdated;
}

/// Failed API call; [message] for user, optional [lastKnown] to display.
class AqiFailure extends AqiResult {
  const AqiFailure({
    required this.message,
    this.lastKnown,
  });

  final String message;
  final AqiData? lastKnown;
}

/// Most recent AQI: value, category label, and location used for the query.
class AqiData {
  const AqiData({
    required this.aqiValue,
    required this.category,
    required this.locationLabel,
    this.reportingArea,
    this.stateCode,
  });

  final int aqiValue;
  final String category;
  final String locationLabel;
  /// City/area name from the AirNow API (e.g. "Boise"). Used to drive the
  /// AirNow forecast widget URL when the user location is a ZIP or GPS fix.
  final String? reportingArea;
  /// Two-letter US state code from the AirNow API (e.g. "ID").
  final String? stateCode;
}
