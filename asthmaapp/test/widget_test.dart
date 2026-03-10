// Basic Flutter widget test for Asthma Activity Advisor.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/aqi_result.dart';
import 'package:asthmaapp/models/recommendation_args.dart';
import 'package:asthmaapp/pages/recommendation_page.dart';
import 'package:asthmaapp/services/aqi_service.dart';
import 'package:asthmaapp/widgets/symptom_modal.dart';

void main() {
  testWidgets('App launches to home page with symptom and location inputs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsthmaActivityAdvisorApp());

    expect(find.text('Asthma Activity Advisor'), findsOneWidget);
    expect(find.text('Get activity recommendation'), findsOneWidget);
  });

  testWidgets('AQI displays correctly after manual location entry',
      (WidgetTester tester) async {
    final stubService = _StubAqiService();

    await tester.pumpWidget(
      MaterialApp(
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
              builder: (_) => RecommendationPage(aqiService: stubService),
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

  testWidgets('Unknown city or ZIP shows clear error and retry',
      (WidgetTester tester) async {
    final failingService = _FailingAqiService();

    await tester.pumpWidget(
      MaterialApp(
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
              builder: (_) => RecommendationPage(aqiService: failingService),
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
  Future<AqiResult> getAqiForCoordinates(double latitude, double longitude) async {
    return AqiSuccess(
      data: const AqiData(
        aqiValue: 55,
        category: 'Moderate',
        locationLabel: 'Current location',
      ),
      lastUpdated: null,
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
  Future<AqiResult> getAqiForCoordinates(double latitude, double longitude) async {
    return const AqiFailure(
      message: 'No air quality data for this area. Try a nearby city or ZIP code.',
    );
  }
}
