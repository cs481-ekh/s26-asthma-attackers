import '../models/aqi_result.dart';

/// Abstract interface for Air Quality Index (AQI) data services.
///
/// This interface defines the contract for services that provide current air
/// quality information. Implementations should fetch real-time AQI data from
/// monitoring stations and return standardized results.
///
/// ## Supported Location Types
/// - **Text locations**: ZIP codes (e.g., "83702") or city names
/// - **Geographic coordinates**: Latitude/longitude pairs from device GPS
///
/// ## Result Types
/// - [AqiSuccess]: Contains valid AQI data with value, category, and location
/// - [AqiFailure]: Contains error message when data cannot be retrieved
///
/// ## Current Implementation
/// - [AirNowAqiService]: Uses EPA AirNow API for US air quality data
/// - API Documentation: https://docs.airnowapi.org/obs/docs
/// - Data Source: https://www.airnowapi.org/CurrentObservationsByZip/query
abstract class AqiService {
  /// Retrieves current air quality data for a text-based location.
  ///
  /// [locationInput] should be a valid US ZIP code (5 digits) or city name.
  /// The service will search for monitoring stations within a reasonable
  /// radius of the location and return the most relevant AQI data.
  ///
  /// Returns [AqiSuccess] with current AQI information, or [AqiFailure]
  /// if the location is invalid, no data is available, or the request fails.
  Future<AqiResult> getAqiForLocation(String locationInput);

  /// Retrieves current air quality data for geographic coordinates.
  ///
  /// [latitude] and [longitude] should be valid WGS84 coordinates in decimal degrees.
  /// The service will search for monitoring stations within a reasonable
  /// radius of the coordinates and return the most relevant AQI data.
  ///
  /// [locationLabel] is an optional display name (e.g. "Current location" when
  /// from device geolocation) used in the returned AQI result.
  ///
  /// Returns [AqiSuccess] with current AQI information, or [AqiFailure]
  /// if no data is available for the coordinates or the request fails.
  Future<AqiResult> getAqiForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
  });

  /// Retrieves forecast air quality data for a text-based location.
  ///
  /// [dayOffset] is the number of days from today:
  /// - `0` for today's forecast
  /// - `1` for next-day forecast
  Future<AqiResult> getForecastForLocation(
    String locationInput, {
    int dayOffset = 1,
  });

  /// Retrieves forecast air quality data for geographic coordinates.
  ///
  /// [dayOffset] is the number of days from today:
  /// - `0` for today's forecast
  /// - `1` for next-day forecast
  Future<AqiResult> getForecastForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
    int dayOffset = 1,
  });
}
