import 'package:asthmaapp/models/aqi_result.dart';
import 'package:asthmaapp/models/recommendation_args.dart';
import 'package:asthmaapp/pages/recommendation_page.dart';
import 'package:asthmaapp/services/aqi_service.dart';
import 'package:asthmaapp/services/locale_service.dart';
import 'package:asthmaapp/l10n/app_localizations.dart';
import 'package:asthmaapp/widgets/symptom_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('RecommendationPage', () {
    testWidgets('loads and displays AQI for ZIP input', (
      WidgetTester tester,
    ) async {
      final service = _QueueAqiService(
        locationResults: [_successResult(locationLabel: '83702', aqiValue: 55, category: 'Moderate')],
      );

      await _pumpRecommendationPage(
        tester,
        aqiService: service,
        args: const RecommendationArgs(
          symptomLevel: SymptomLevel.a,
          location: '83702',
        ),
      );

      expect(find.text('Location: 83702'), findsOneWidget);
      expect(find.text('AQI: 55  •  Moderate'), findsOneWidget);
      expect(service.locationRequestCount, 1);
      expect(service.coordinateRequestCount, 0);
    });

    testWidgets('loads AQI for geolocation input', (
      WidgetTester tester,
    ) async {
      final service = _QueueAqiService(
        coordinateResults: [
          _successResult(
            locationLabel: 'Current location',
            aqiValue: 40,
            category: 'Good',
          ),
        ],
      );

      await _pumpRecommendationPage(
        tester,
        aqiService: service,
        args: const RecommendationArgs(
          symptomLevel: SymptomLevel.b,
          location: 'Current location',
          latitude: 43.6,
          longitude: -116.2,
        ),
      );

      expect(find.text('Location: Current location'), findsOneWidget);
      expect(find.text('AQI: 40  •  Good'), findsOneWidget);
      expect(service.coordinateRequestCount, 1);
      expect(service.locationRequestCount, 0);
    });

    testWidgets('supports retry flow for a failed typed location lookup', (
      WidgetTester tester,
    ) async {
      final service = _QueueAqiService(
        locationResults: [
          const AqiFailure(
            message: 'No air quality data for this area. Try a nearby city or ZIP code.',
          ),
          _successResult(locationLabel: '83702', aqiValue: 55, category: 'Moderate'),
        ],
      );

      await _pumpRecommendationPage(
        tester,
        aqiService: service,
        args: const RecommendationArgs(
          symptomLevel: SymptomLevel.a,
          location: '83702',
        ),
      );

      expect(
        find.text(
          'No air quality data for this area. Try a nearby city or ZIP code.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Location: 83702'), findsOneWidget);
      expect(find.text('AQI: 55  •  Moderate'), findsOneWidget);
      expect(service.locationRequestCount, 2);
    });

    testWidgets('supports retry flow for failed geolocation AQI', (
      WidgetTester tester,
    ) async {
      final service = _QueueAqiService(
        coordinateResults: [
          const AqiFailure(
            message: 'No air quality data for your location. Try a nearby city or ZIP code.',
          ),
          _successResult(
            locationLabel: 'Current location',
            aqiValue: 42,
            category: 'Good',
          ),
        ],
      );

      await _pumpRecommendationPage(
        tester,
        aqiService: service,
        args: const RecommendationArgs(
          symptomLevel: SymptomLevel.c,
          location: 'Current location',
          latitude: 45.0,
          longitude: -120.0,
        ),
      );

      expect(
        find.text('No air quality data for your location. Try a nearby city or ZIP code.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Location: Current location'), findsOneWidget);
      expect(find.text('AQI: 42  •  Good'), findsOneWidget);
      expect(service.coordinateRequestCount, 2);
    });

    testWidgets('shows next-day forecast guidance', (
      WidgetTester tester,
    ) async {
      final service = _QueueAqiService(
        locationResults: [_successResult(locationLabel: '83702', aqiValue: 55, category: 'Moderate')],
        forecastLocationResults: [
          _successResult(locationLabel: '83702', aqiValue: 160, category: 'Unhealthy'),
        ],
      );

      await _pumpRecommendationPage(
        tester,
        aqiService: service,
        args: const RecommendationArgs(
          symptomLevel: SymptomLevel.a,
          location: '83702',
        ),
      );

      final nextDayButton = find.text('View next-day activity guidance');
      await tester.ensureVisible(nextDayButton);
      await tester.tap(nextDayButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Next-day activity guidance'), findsOneWidget);
      expect(find.text('Forecast AQI: 160 (Unhealthy)'), findsOneWidget);
      expect(find.text('Medium activity: Not recommended'), findsOneWidget);
      expect(find.text('Vigorous activity: Not recommended'), findsOneWidget);
      expect(service.forecastLocationRequestCount, 1);
    });
  });

  group('cityStateForAirNowEmbed', () {
    test('merges API state when user types city without state', () {
      final resolved = cityStateForAirNowEmbed(
        location: 'Boise',
        aqiResult: _successResult(
          locationLabel: 'Boise, ID',
          aqiValue: 42,
          category: 'Good',
          reportingArea: 'Boise',
          stateCode: 'ID',
        ),
      );
      expect(resolved?.city, 'Boise');
      expect(resolved?.state, 'ID');
    });
  });
}

Future<void> _pumpRecommendationPage(
  WidgetTester tester, {
  required AqiService aqiService,
  required RecommendationArgs args,
}) async {
  final localeNotifier = ValueNotifier<Locale?>(const Locale('en'));
  await tester.pumpWidget(
    MaterialApp(
      locale: localeNotifier.value,
      supportedLocales: LocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(
              RecommendationPage.routeName,
              arguments: args,
            ),
            child: const Text('Go to recommendation'),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == RecommendationPage.routeName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => RecommendationPage(
              aqiService: aqiService,
              localeNotifier: localeNotifier,
            ),
          );
        }
        return null;
      },
    ),
  );

  await tester.tap(find.text('Go to recommendation'));
  await tester.pump();
  await tester.pumpAndSettle();
}

AqiSuccess _successResult({
  required String locationLabel,
  required int aqiValue,
  required String category,
  String? reportingArea,
  String? stateCode,
}) {
  return AqiSuccess(
    data: AqiData(
      aqiValue: aqiValue,
      category: category,
      locationLabel: locationLabel,
      reportingArea: reportingArea,
      stateCode: stateCode,
    ),
    lastUpdated: DateTime(2026, 4, 13, 10),
  );
}

class _QueueAqiService implements AqiService {
  _QueueAqiService({
    List<AqiResult>? locationResults,
    List<AqiResult>? coordinateResults,
    List<AqiResult>? forecastLocationResults,
    List<AqiResult>? forecastCoordinateResults,
  })  : _locationResults = locationResults ?? <AqiResult>[],
        _coordinateResults = coordinateResults ?? <AqiResult>[],
        _forecastLocationResults = forecastLocationResults ?? <AqiResult>[],
        _forecastCoordinateResults = forecastCoordinateResults ?? <AqiResult>[];

  final List<AqiResult> _locationResults;
  final List<AqiResult> _coordinateResults;
  final List<AqiResult> _forecastLocationResults;
  final List<AqiResult> _forecastCoordinateResults;

  int locationRequestCount = 0;
  int coordinateRequestCount = 0;
  int forecastLocationRequestCount = 0;
  int forecastCoordinateRequestCount = 0;

  @override
  Future<AqiResult> getAqiForLocation(String locationInput) async {
    locationRequestCount++;
    return _nextResult(_locationResults);
  }

  @override
  Future<AqiResult> getAqiForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
  }) async {
    coordinateRequestCount++;
    return _nextResult(_coordinateResults);
  }

  @override
  Future<AqiResult> getForecastForLocation(
    String locationInput, {
    int dayOffset = 1,
  }) async {
    forecastLocationRequestCount++;
    return _nextResult(_forecastLocationResults);
  }

  @override
  Future<AqiResult> getForecastForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
    int dayOffset = 1,
  }) async {
    forecastCoordinateRequestCount++;
    return _nextResult(_forecastCoordinateResults);
  }

  AqiResult _nextResult(List<AqiResult> results) {
    if (results.isEmpty) {
      throw StateError('Missing stubbed AQI result for test call.');
    }
    if (results.length == 1) {
      return results.first;
    }
    return results.removeAt(0);
  }
}