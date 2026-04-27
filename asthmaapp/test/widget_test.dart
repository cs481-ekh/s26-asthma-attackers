// Basic Flutter widget test for Asthma Activity Advisor.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/aqi_result.dart';
import 'package:asthmaapp/models/recommendation_args.dart';
import 'package:asthmaapp/pages/recommendation_page.dart';
import 'package:asthmaapp/services/aqi_service.dart';
import 'package:asthmaapp/services/locale_service.dart';
import 'package:asthmaapp/l10n/app_localizations.dart';
import 'package:asthmaapp/widgets/symptom_modal.dart';

void main() {
  testWidgets('App launches to home page with symptom and location inputs',
      (WidgetTester tester) async {
    await tester.pumpWidget(AsthmaActivityAdvisorApp());

    expect(find.text('Asthma Activity Advisor'), findsOneWidget);
    expect(find.text('Get activity recommendation'), findsOneWidget);
  });

  testWidgets('AQI displays correctly after manual location entry',
      (WidgetTester tester) async {
    final stubService = _StubAqiService();
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
                arguments: RecommendationArgs(
                  symptomLevel: SymptomLevel.a,
                  location: '83702',
                ),
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
                aqiService: stubService,
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

    expect(find.text('Location: 83702'), findsOneWidget);
    expect(find.textContaining('AQI: 55'), findsOneWidget);
    expect(find.textContaining('Moderate'), findsOneWidget);
  });

  testWidgets('Geolocation: AQI and location displayed correctly for device location',
      (WidgetTester tester) async {
    final stubService = _StubAqiService();
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
                arguments: RecommendationArgs(
                  symptomLevel: SymptomLevel.b,
                  location: 'Current location',
                  latitude: 43.6,
                  longitude: -116.2,
                ),
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
                aqiService: stubService,
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

    expect(find.text('Location: Current location'), findsOneWidget);
    expect(find.textContaining('AQI:'), findsOneWidget);
    expect(find.textContaining('Good'), findsOneWidget);
  });

  testWidgets('Geolocation: error shown and Retry available when API fails for location',
      (WidgetTester tester) async {
    final failingService = _FailingAqiService();
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
                arguments: RecommendationArgs(
                  symptomLevel: SymptomLevel.a,
                  location: 'Current location',
                  latitude: 45.0,
                  longitude: -120.0,
                ),
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
                aqiService: failingService,
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

    expect(find.textContaining('No air quality data for your location'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Unknown city or ZIP shows clear error and retry',
      (WidgetTester tester) async {
    final failingService = _FailingAqiService();
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
                arguments: RecommendationArgs(
                  symptomLevel: SymptomLevel.a,
                  location: 'InvalidPlace999',
                ),
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
                aqiService: failingService,
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

    expect(find.textContaining('Could not find that city or place'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Next-day guidance shows forecast-based recommendations',
      (WidgetTester tester) async {
    final stubService = _StubAqiService();
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
                arguments: RecommendationArgs(
                  symptomLevel: SymptomLevel.a,
                  location: '83702',
                ),
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
                aqiService: stubService,
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

    final nextDayButton = find.text('View next-day activity guidance');
    await tester.ensureVisible(nextDayButton);
    await tester.tap(nextDayButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Next-day activity guidance'), findsOneWidget);
    expect(find.text('Forecast AQI: 160 (Unhealthy)'), findsOneWidget);
    expect(find.text('Medium activity: Not recommended'), findsOneWidget);
    expect(find.text('Vigorous activity: Not recommended'), findsOneWidget);
  });
}

class _StubAqiService implements AqiService {
  @override
  Future<AqiResult> getAqiForLocation(String locationInput) async {
    return AqiSuccess(
      data: AqiData(
        aqiValue: 55,
        category: 'Moderate',
        locationLabel: locationInput,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<AqiResult> getAqiForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
  }) async {
    return AqiSuccess(
      data: AqiData(
        aqiValue: 40,
        category: 'Good',
        locationLabel: locationLabel ?? 'Current location',
      ),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<AqiResult> getForecastForLocation(
    String locationInput, {
    int dayOffset = 1,
  }) async {
    return AqiSuccess(
      data: AqiData(
        aqiValue: 160,
        category: 'Unhealthy',
        locationLabel: locationInput,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<AqiResult> getForecastForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
    int dayOffset = 1,
  }) async {
    return AqiSuccess(
      data: AqiData(
        aqiValue: 160,
        category: 'Unhealthy',
        locationLabel: locationLabel ?? 'Current location',
      ),
      lastUpdated: DateTime.now(),
    );
  }
}

class _FailingAqiService implements AqiService {
  @override
  Future<AqiResult> getAqiForLocation(String locationInput) async {
    return const AqiFailure(
      message: 'Could not find that city or place. Try a ZIP code or a different spelling.',
    );
  }

  @override
  Future<AqiResult> getAqiForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
  }) async {
    return const AqiFailure(
      message: 'No air quality data for your location. Try a nearby city or ZIP code.',
    );
  }

  @override
  Future<AqiResult> getForecastForLocation(
    String locationInput, {
    int dayOffset = 1,
  }) async {
    return const AqiFailure(
      message: 'No forecast data for this area. Try a nearby city or ZIP code.',
    );
  }

  @override
  Future<AqiResult> getForecastForCoordinates(
    double latitude,
    double longitude, {
    String? locationLabel,
    int dayOffset = 1,
  }) async {
    return const AqiFailure(
      message: 'No forecast data for your location. Try a nearby city or ZIP code.',
    );
  }
}
