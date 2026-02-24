import '../models/aqi_result.dart';

/// Fetches AQI for a location (ZIP/city or coordinates).
/// Real implementation: EPA AirNow by ZIP or by lat/long.
/// https://www.airnowapi.org/CurrentObservationsByZip/query
/// https://docs.airnowapi.org/obs/docs
abstract class AqiService {
  /// Returns current AQI for the given location input (ZIP or city name).
  Future<AqiResult> getAqiForLocation(String locationInput);

  /// Returns current AQI for the given coordinates (e.g. from device geolocation).
  Future<AqiResult> getAqiForCoordinates(double latitude, double longitude);
}
