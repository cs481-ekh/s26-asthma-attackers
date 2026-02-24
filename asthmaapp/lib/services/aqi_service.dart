import '../models/aqi_result.dart';

/// Fetches AQI for a location (ZIP code or city).
/// Real implementation should call EPA AirNow API:
/// https://www.airnowapi.org/CurrentObservationsByZip/query
abstract class AqiService {
  /// Returns current AQI for the given location input (ZIP or city name).
  /// [locationInput] is the user-entered ZIP code or city (e.g. "83702" or "Boise").
  Future<AqiResult> getAqiForLocation(String locationInput);
}
