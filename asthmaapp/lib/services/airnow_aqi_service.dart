import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/aqi_result.dart';
import '../utils/location_validator.dart';
import 'aqi_service.dart';

/// Air Quality Index (AQI) service implementation using the EPA AirNow API.
///
/// This service provides air quality data by querying the EPA's AirNow API,
/// which aggregates data from thousands of monitoring stations across the United States.
/// The service prioritizes PM2.5 particulate matter data as the primary air quality indicator.
///
/// ## Data Sources & Priority
/// - **Primary**: Current air quality observations from EPA monitoring stations (real-time)
/// - **Fallback**: Today's air quality forecast when observations are unavailable
/// - **Coverage**: Continental US, Alaska, Hawaii, and US territories
/// - **Update Frequency**: Real-time data (observations) or daily forecasts
///
/// ## Location Support
/// - **ZIP Code queries**: Searches within 25-mile radius of ZIP code centroid
/// - **Coordinate queries**: Searches within 25-mile radius of provided coordinates
/// - **Multi-station handling**: Prioritizes data from primary reporting area when multiple stations are found
///
/// ## Error Handling
/// - Network timeouts (20-second limit for AirNow; 12s for geocoding)
/// - Invalid API keys or parameters
/// - No data available for location
/// - Malformed API responses
///
/// ## Dependencies
/// - Requires `AIRNOW_API_KEY` environment variable (obtain from airnowapi.org)
/// - Uses flutter_dotenv for secure API key management
///
/// ## Usage Example
/// ```dart
/// final service = AirNowAqiService();
/// final result = await service.getAqiForLocation('83702'); // Boise, ID
/// if (result is AqiSuccess) {
///   print('AQI: ${result.data.aqiValue} (${result.data.category})');
/// }
/// ```
class AirNowAqiService implements AqiService {
  static const String _apiKeyFromDefine = String.fromEnvironment(
    'AIRNOW_API_KEY',
    defaultValue: '',
  );

  static String? _resolveApiKey() {
    final fromDotEnv = dotenv.env['AIRNOW_API_KEY'];
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) {
      return fromDotEnv;
    }
    if (_apiKeyFromDefine.isNotEmpty) {
      return _apiKeyFromDefine;
    }
    return null;
  }

  /// Creates an AirNow AQI service instance.
  ///
  /// [simulateFailure] - If true, always returns failure for testing error states
  /// [httpClient] - Optional HTTP client for dependency injection (defaults to http.Client)
  ///
  /// The service automatically loads the API key from the AIRNOW_API_KEY environment variable.
  AirNowAqiService({this.simulateFailure = false, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client(),
        _apiKey = _resolveApiKey();

  /// Whether to simulate service failures for testing purposes.
  final bool simulateFailure;

  /// HTTP client used for API requests.
  final http.Client _httpClient;

  /// AirNow API key loaded from environment variables.
  final String? _apiKey;

  /// Base URL for ZIP code-based observation queries.
  ///
  /// Searches for current air quality observations within 25 miles of the ZIP code centroid.
  /// Returns JSON array of monitoring station data.
  static const String _observationZipUrl =
      'https://www.airnowapi.org/aq/observation/zipCode/current/';

  /// Base URL for coordinate-based observation queries.
  ///
  /// Searches for current air quality observations within 25 miles of the provided coordinates.
  /// Returns JSON array of monitoring station data.
  static const String _observationCoordsUrl =
      'https://www.airnowapi.org/aq/observation/latLong/current/';

  /// Base URL for ZIP code-based forecast queries.
  ///
  /// Retrieves air quality forecast for today within 25 miles of the ZIP code centroid.
  /// Used as fallback when current observations are unavailable.
  static const String _forecastZipUrl =
      'https://www.airnowapi.org/aq/forecast/zipCode/';

  /// Base URL for coordinate-based forecast queries.
  ///
  /// Retrieves air quality forecast for today within 25 miles of the provided coordinates.
  /// Used as fallback when current observations are unavailable.
  static const String _forecastCoordsUrl =
      'https://www.airnowapi.org/aq/forecast/latLong/';

  /// Timeout duration for AirNow API requests (coordinate/ZIP can be slow).
  static const Duration _timeout = Duration(seconds: 20);

  @override
  Future<AqiResult> getAqiForLocation(String locationInput) async {
    /// Retrieves current air quality data for a location: ZIP code or city/place name.
    /// City names are geocoded to coordinates, then AQI is fetched via coordinate API.
    ///
    /// [locationInput] - ZIP code (e.g. "83702") or city/place name (e.g. "Boise", "New York").
    /// City names are geocoded to coordinates via OpenStreetMap Nominatim, then AQI
    /// is fetched using the coordinate-based AirNow API.
    ///
    /// Returns [AqiSuccess] with current AQI data if available, or [AqiFailure]
    /// with an error message if the request fails or no data is available.
    final trimmed = locationInput.trim();

    if (simulateFailure) {
      return const AqiFailure(
        message: 'Unable to load air quality data. Check your connection and try again.',
      );
    }

    if (trimmed.isEmpty) {
      return const AqiFailure(
        message: 'Please enter a ZIP code or city on the home screen.',
      );
    }

    if (_apiKey == null || _apiKey.isEmpty) {
      return const AqiFailure(
        message: 'API key not configured.',
      );
    }

    try {
      if (LocationValidator.isValidZipCode(trimmed)) {
        // ZIP code path: use AirNow ZIP endpoints directly
        final observationResult = await _fetchObservationForZip(trimmed);
        if (observationResult != null) return observationResult;
        final forecastResult = await _fetchForecastForZip(trimmed);
        if (forecastResult != null) return forecastResult;
      } else {
        // City/place path: geocode to coordinates, then use coordinate endpoints
        final coords = await _geocodePlace(trimmed);
        if (coords == null) {
          return const AqiFailure(
            message: 'Could not find that city or place. Try a ZIP code or a different spelling.',
          );
        }
        final observationResult = await _fetchObservationForCoords(
          coords.latitude,
          coords.longitude,
          locationLabel: trimmed,
        );
        if (observationResult != null) return observationResult;
        final forecastResult = await _fetchForecastForCoords(
          coords.latitude,
          coords.longitude,
          locationLabel: trimmed,
        );
        if (forecastResult != null) return forecastResult;
      }

      return const AqiFailure(
        message: 'No air quality data for this area. Try a nearby city or ZIP code.',
      );
    } on TimeoutException {
      return const AqiFailure(
        message: 'Request timed out. Check your connection and try again.',
      );
    } catch (e) {
      return AqiFailure(
        message: 'Error: $e',
      );
    }
  }

  @override
  Future<AqiResult> getAqiForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
  }) async {
    if (simulateFailure) {
      return const AqiFailure(
        message: 'Unable to load air quality data. Check your connection and try again.',
      );
    }

    if (_apiKey == null || _apiKey.isEmpty) {
      return const AqiFailure(
        message: 'API key not configured.',
      );
    }

    try {
      final observationResult = await _fetchObservationForCoords(
        latitude,
        longitude,
        locationLabel: locationLabel,
      );
      if (observationResult != null) return observationResult;

      final forecastResult = await _fetchForecastForCoords(
        latitude,
        longitude,
        locationLabel: locationLabel,
      );
      if (forecastResult != null) return forecastResult;

      return const AqiFailure(
        message: 'No air quality data for your location. Try a nearby city or ZIP code.',
      );
    } on TimeoutException {
      return const AqiFailure(
        message: 'Request timed out. The air quality service may be slow. Tap Retry to try again.',
      );
    } catch (e) {
      return AqiFailure(
        message: 'Could not load air quality for your location. Tap Retry or try entering a city or ZIP.',
      );
    }
  }

  @override
  Future<AqiResult> getForecastForLocation(
    String locationInput, {
    int dayOffset = 1,
  }) async {
    final trimmed = locationInput.trim();

    if (simulateFailure) {
      return const AqiFailure(
        message: 'Unable to load air quality data. Check your connection and try again.',
      );
    }

    if (trimmed.isEmpty) {
      return const AqiFailure(
        message: 'Please enter a ZIP code or city on the home screen.',
      );
    }

    if (_apiKey == null || _apiKey.isEmpty) {
      return const AqiFailure(
        message: 'API key not configured.',
      );
    }

    try {
      if (LocationValidator.isValidZipCode(trimmed)) {
        final forecastResult = await _fetchForecastForZip(
          trimmed,
          dayOffset: dayOffset,
        );
        if (forecastResult != null) return forecastResult;
      } else {
        final coords = await _geocodePlace(trimmed);
        if (coords == null) {
          return const AqiFailure(
            message: 'Could not find that city or place. Try a ZIP code or a different spelling.',
          );
        }
        final forecastResult = await _fetchForecastForCoords(
          coords.latitude,
          coords.longitude,
          locationLabel: trimmed,
          dayOffset: dayOffset,
        );
        if (forecastResult != null) return forecastResult;
      }

      return const AqiFailure(
        message: 'No forecast data for this area. Try a nearby city or ZIP code.',
      );
    } on TimeoutException {
      return const AqiFailure(
        message: 'Request timed out. Check your connection and try again.',
      );
    } catch (e) {
      return AqiFailure(
        message: 'Error: $e',
      );
    }
  }

  @override
  Future<AqiResult> getForecastForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
    int dayOffset = 1,
  }) async {
    if (simulateFailure) {
      return const AqiFailure(
        message: 'Unable to load air quality data. Check your connection and try again.',
      );
    }

    if (_apiKey == null || _apiKey.isEmpty) {
      return const AqiFailure(
        message: 'API key not configured.',
      );
    }

    try {
      final forecastResult = await _fetchForecastForCoords(
        latitude,
        longitude,
        locationLabel: locationLabel,
        dayOffset: dayOffset,
      );
      if (forecastResult != null) return forecastResult;

      return const AqiFailure(
        message: 'No forecast data for your location. Try a nearby city or ZIP code.',
      );
    } on TimeoutException {
      return const AqiFailure(
        message: 'Request timed out. The air quality service may be slow-tap Retry to try again.',
      );
    } catch (e) {
      return AqiFailure(
        message: 'Could not load forecast for your location. Tap Retry or try entering a city or ZIP.',
      );
    }
  }

  /// Fetches current AQI observations for a ZIP code location.
  ///
  /// Makes an HTTP GET request to the AirNow observation API with the provided
  /// ZIP code and searches within a 25-mile radius. Handles common HTTP error
  /// codes and returns appropriate failure messages.
  ///
  /// Returns [AqiSuccess] if valid observation data is found, [AqiFailure] if
  /// the request fails or no data is available, or null if parsing fails.
  Future<AqiResult?> _fetchObservationForZip(String zipCode) async {
    try {
      final uri = Uri.parse(_observationZipUrl).replace(
        queryParameters: {
          'format': 'application/json',
          'zipCode': zipCode,
          'distance': '5',
          'API_KEY': _apiKey,
        },
      );

      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode == 401) {
        return const AqiFailure(message: 'Invalid API key.');
      }
      if (response.statusCode == 400) {
        return const AqiFailure(
          message: 'We couldn\'t find air quality data for that ZIP code. Try a nearby city or ZIP, or check the number.',
        );
      }
      if (response.statusCode != 200) {
        return AqiFailure(message: 'API error: ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        return null;
      }

      final result = _parseObservationResponse(response.body, zipCode);
      return result;
    } on TimeoutException {
      return const AqiFailure(
        message: 'Request timed out. The air quality service may be slow—tap Retry to try again.',
      );
    } catch (e) {
      return AqiFailure(message: 'Observation fetch error: $e');
    }
  }

  /// Fetches current AQI observations for geographic coordinates.
  /// [locationLabel] - Optional display name (e.g. "Current location" from geolocation).
  Future<AqiResult?> _fetchObservationForCoords(
    double latitude,
    double longitude, {
    String? locationLabel,
  }) async {
    try {
      final uri = Uri.parse(_observationCoordsUrl).replace(
        queryParameters: {
          'format': 'application/json',
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'distance': '25',
          'API_KEY': _apiKey,
        },
      );

      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode == 401) {
        return const AqiFailure(message: 'Invalid API key.');
      }
      if (response.statusCode != 200) {
        return AqiFailure(message: 'API error: ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        return null;
      }

      final label = locationLabel ?? 'Latitude: $latitude, Longitude: $longitude';
      return _parseObservationResponse(response.body, label);
    } on TimeoutException {
      return const AqiFailure(
        message: 'Request timed out. The air quality service may be slow—tap Retry to try again.',
      );
    } catch (e) {
      return AqiFailure(message: 'Observation fetch error: $e');
    }
  }

  /// Fetches AQI forecast for ZIP code (fallback when observations unavailable).
  ///
  /// Makes an HTTP GET request to the AirNow forecast API for today's forecast
  /// within 25 miles of the ZIP code centroid. Used as fallback when current
  /// observations are not available.
  ///
  /// Returns [AqiSuccess] if valid forecast data is found, [AqiFailure] if
  /// the request fails or no data is available, or null if parsing fails.
  Future<AqiResult?> _fetchForecastForZip(
    String zipCode, {
    int dayOffset = 0,
  }) async {
    final targetDate = DateTime.now().add(Duration(days: dayOffset));
    final dateString = _formatDate(targetDate);

    final uri = Uri.parse(_forecastZipUrl).replace(
      queryParameters: {
        'format': 'application/json',
        'zipCode': zipCode,
        'distance': '25',
        'date': dateString,
        'API_KEY': _apiKey,
      },
    );

    final response = await _httpClient.get(uri).timeout(_timeout);

    if (response.statusCode == 401) {
      return const AqiFailure(message: 'Invalid API key.');
    }
    if (response.statusCode == 400) {
      return const AqiFailure(
        message: 'We couldn\'t find air quality data for that ZIP code. Try a nearby city or ZIP, or check the number.',
      );
    }
    if (response.statusCode != 200) {
      return AqiFailure(message: 'Server error: ${response.statusCode}');
    }

    if (response.body.isEmpty) {
      return null;
    }

    return _parseForecastResponse(
      response.body,
      zipCode,
      targetDate: targetDate,
    );
  }

  /// Fetches AQI forecast for coordinates (fallback when observations unavailable).
  ///
  /// [locationLabel] - Optional display name for the result (e.g. city name when geocoded).
  Future<AqiResult?> _fetchForecastForCoords(
    double latitude,
    double longitude, {
    String? locationLabel,
    int dayOffset = 0,
  }) async {
    final targetDate = DateTime.now().add(Duration(days: dayOffset));
    final dateString = _formatDate(targetDate);

    final uri = Uri.parse(_forecastCoordsUrl).replace(
      queryParameters: {
        'format': 'application/json',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'distance': '25',
        'date': dateString,
        'API_KEY': _apiKey,
      },
    );

    final response = await _httpClient.get(uri).timeout(_timeout);

    if (response.statusCode == 401) {
      return const AqiFailure(message: 'Invalid API key.');
    }
    if (response.statusCode != 200) {
      return AqiFailure(message: 'Server error: ${response.statusCode}');
    }

    if (response.body.isEmpty) {
      return null;
    }

    final label = locationLabel ?? 'Latitude: $latitude, Longitude: $longitude';
    return _parseForecastResponse(
      response.body,
      label,
      targetDate: targetDate,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Geocodes a place name (e.g. city) to coordinates using OpenStreetMap Nominatim.
  /// Appends ", USA" to bias US results for AirNow coverage.
  /// Returns null if the place cannot be found or the request fails.
  Future<({double latitude, double longitude})?> _geocodePlace(String placeName) async {
    try {
      final query = placeName.contains(',') ? placeName : '$placeName, USA';
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '1',
        },
      );
      final response = await _httpClient.get(
        uri,
        headers: {
          'User-Agent': 'AsthmaActivityAdvisor/1.0 (educational; air quality app)',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return null;

      final list = jsonDecode(response.body);
      if (list is! List<dynamic> || list.isEmpty) return null;

      final first = list.first;
      if (first is! Map<String, dynamic>) return null;

      final lat = first['lat'];
      final lon = first['lon'];
      if (lat == null || lon == null) return null;

      final latitude = double.tryParse(lat.toString());
      final longitude = double.tryParse(lon.toString());
      if (latitude == null || longitude == null) return null;

      return (latitude: latitude, longitude: longitude);
    } catch (_) {
      return null;
    }
  }

  /// Parses the JSON response from the AirNow observation API.
  ///
  /// The API returns an array of monitoring station observations, potentially
  /// from multiple stations within the search radius. Each observation includes
  /// pollutant type (PM2.5, PM10, O3, etc.), AQI value, and reporting area.
  ///
  /// Selection Priority (highest to lowest):
  /// 1. PM2.5 from primary reporting area (first valid station found)
  /// 2. PM2.5 from any nearby reporting area
  /// 3. Other pollutants (PM10, O3, etc.) from any area
  ///
  /// [responseBody] - Raw JSON response string from the API
  /// [locationLabel] - Human-readable location description for the result
  ///
  /// Returns [AqiSuccess] with the best available AQI data, or [AqiFailure]
  /// if no valid data can be parsed.
  AqiResult _parseObservationResponse(String responseBody, String locationLabel) {
    try {
      final jsonData = jsonDecode(responseBody) as List<dynamic>;

      if (jsonData.isEmpty) {
        return const AqiFailure(message: 'No observation data available.');
      }

      // Use records so we can carry reporting area / state alongside each entry.
      String? primaryReportingArea;
      List<({int aqi, String category, String? reportingArea, String? stateCode})> pm25Results = [];
      List<({int aqi, String category, String? reportingArea, String? stateCode})> pm25PrimaryResults = [];
      List<({int aqi, String category, String? reportingArea, String? stateCode})> otherResults = [];

      for (int i = 0; i < jsonData.length; i++) {
        final entry = jsonData[i];
        if (entry is! Map<String, dynamic>) continue;

        final map = entry;
        final aqi = map['AQI'] as int?;
        final parameterName = map['ParameterName'] as String?;
        final reportingArea = map['ReportingArea'] as String?;
        final stateCode = map['StateCode'] as String?;

        if (aqi != null && aqi >= 0) {
          final category = map['Category'] as Map<String, dynamic>?;
          final categoryName = category?['Name'] as String?;

          if (categoryName != null && categoryName.isNotEmpty) {
            final record = (
              aqi: aqi,
              category: categoryName,
              reportingArea: reportingArea,
              stateCode: stateCode,
            );

            if (primaryReportingArea == null && reportingArea != null) {
              primaryReportingArea = reportingArea;
            }

            if (parameterName == 'PM2.5') {
              pm25Results.add(record);
              if (reportingArea == primaryReportingArea) {
                pm25PrimaryResults.add(record);
              }
            } else {
              otherResults.add(record);
            }
          }
        }
      }

      // Return best available data based on priority hierarchy
      // 1. PM2.5 from primary reporting area (most relevant)
      // 2. PM2.5 from any nearby area
      // 3. Other pollutants as fallback
      ({int aqi, String category, String? reportingArea, String? stateCode})? best;
      if (pm25PrimaryResults.isNotEmpty) {
        best = pm25PrimaryResults.first;
      } else if (pm25Results.isNotEmpty) {
        best = pm25Results.first;
      } else if (otherResults.isNotEmpty) {
        best = otherResults.first;
      }

      if (best != null) {
        return AqiSuccess(
          data: AqiData(
            aqiValue: best.aqi,
            category: best.category,
            locationLabel: locationLabel,
            reportingArea: best.reportingArea,
            stateCode: best.stateCode,
          ),
          lastUpdated: DateTime.now(),
        );
      }

      return const AqiFailure(message: 'No valid observation data available.');
    } catch (e) {
      return AqiFailure(message: 'Failed to parse observation response: $e');
    }
  }

  /// Parses the JSON response from the AirNow forecast API.
  ///
  /// The forecast API returns an array of forecast entries for the requested date.
  /// Each entry includes pollutant type, forecasted AQI value, and category.
  /// This method finds today's forecast and prioritizes PM2.5 data.
  ///
  /// Selection Priority (highest to lowest):
  /// 1. Today's PM2.5 forecast
  /// 2. Today's forecast for any other pollutant
  /// 3. First valid forecast entry (fallback)
  ///
  /// [responseBody] - Raw JSON response string from the forecast API
  /// [locationLabel] - Human-readable location description for the result
  ///
  /// Returns [AqiSuccess] with the best available forecast data, or [AqiFailure]
  /// if no valid forecast data can be parsed.
  AqiResult _parseForecastResponse(
    String responseBody,
    String locationLabel, {
    required DateTime targetDate,
  }) {
    try {
      final jsonData = jsonDecode(responseBody) as List<dynamic>;

      if (jsonData.isEmpty) {
        return const AqiFailure(message: 'No forecast data available.');
      }

      final targetDateString = _formatDate(targetDate);

      // First try to find today's PM2.5 forecast
      for (final entry in jsonData) {
        if (entry is! Map<String, dynamic>) continue;

        final map = entry;
        final dateForecast = map['DateForecast'] as String?;
        final parameterName = map['ParameterName'] as String?;
        final aqi = map['AQI'] as int?;
        final reportingArea = map['ReportingArea'] as String?;
        final stateCode = map['StateCode'] as String?;

        if (dateForecast == targetDateString && parameterName == 'PM2.5' && aqi != null && aqi >= 0) {
          final category = map['Category'] as Map<String, dynamic>?;
          final categoryName = category?['Name'] as String?;

          if (categoryName != null && categoryName.isNotEmpty) {
            return AqiSuccess(
              data: AqiData(
                aqiValue: aqi,
                category: categoryName,
                locationLabel: locationLabel,
                reportingArea: reportingArea,
                stateCode: stateCode,
              ),
              lastUpdated: DateTime.now(),
            );
          }
        }
      }

      // If no PM2.5 forecast found, fall back to same-date forecast for any pollutant
      for (final entry in jsonData) {
        if (entry is! Map<String, dynamic>) continue;

        final map = entry;
        final dateForecast = map['DateForecast'] as String?;
        final aqi = map['AQI'] as int?;
        final reportingArea = map['ReportingArea'] as String?;
        final stateCode = map['StateCode'] as String?;

        if (dateForecast == targetDateString && aqi != null && aqi >= 0) {
          final category = map['Category'] as Map<String, dynamic>?;
          final categoryName = category?['Name'] as String?;

          if (categoryName != null && categoryName.isNotEmpty) {
            return AqiSuccess(
              data: AqiData(
                aqiValue: aqi,
                category: categoryName,
                locationLabel: locationLabel,
                reportingArea: reportingArea,
                stateCode: stateCode,
              ),
              lastUpdated: DateTime.now(),
            );
          }
        }
      }

      // If no today's forecast found, fall back to first valid forecast entry
      for (final entry in jsonData) {
        if (entry is! Map<String, dynamic>) continue;

        final map = entry;
        final aqi = map['AQI'] as int?;
        final reportingArea = map['ReportingArea'] as String?;
        final stateCode = map['StateCode'] as String?;

        if (aqi != null && aqi >= 0) {
          final category = map['Category'] as Map<String, dynamic>?;
          final categoryName = category?['Name'] as String?;

          if (categoryName != null && categoryName.isNotEmpty) {
            return AqiSuccess(
              data: AqiData(
                aqiValue: aqi,
                category: categoryName,
                locationLabel: locationLabel,
                reportingArea: reportingArea,
                stateCode: stateCode,
              ),
              lastUpdated: DateTime.now(),
            );
          }
        }
      }

      return const AqiFailure(message: 'No valid forecast data available.');
    } catch (e) {
      return AqiFailure(message: 'Failed to parse forecast response: $e');
    }
  }
}
