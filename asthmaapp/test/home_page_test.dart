import 'package:asthmaapp/pages/home_page.dart';
import 'package:asthmaapp/services/locale_service.dart';
import 'package:asthmaapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (methodCall) async => true,
    );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      null,
    );
  });

  group('HomePage', () {
    testWidgets('requires symptom selection before submitting', (
      WidgetTester tester,
    ) async {
      await _prepareViewport(tester);
      await tester.pumpWidget(_buildHomePage());

      await tester.enterText(find.byType(TextField), '83702');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Please select a symptom level first.'), findsOneWidget);
      expect(_submitButton(tester).onPressed, isNull);
    });

    testWidgets('shows a validation message when location is missing', (
      WidgetTester tester,
    ) async {
      await _prepareViewport(tester);
      await tester.pumpWidget(_buildHomePage());
      await _selectSymptom(tester, 'A', 'No respiratory or asthma symptoms');

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Enter a ZIP code or city name.'), findsOneWidget);
      expect(_submitButton(tester).onPressed, isNull);
    });

    testWidgets('shows a validation message for an invalid location', (
      WidgetTester tester,
    ) async {
      await _prepareViewport(tester);
      await tester.pumpWidget(_buildHomePage());
      await _selectSymptom(tester, 'B', 'Few respiratory or asthma symptoms');

      await tester.enterText(find.byType(TextField), '12@#');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(
        find.text(
          'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).',
        ),
        findsOneWidget,
      );
      expect(_submitButton(tester).onPressed, isNull);
    });

    testWidgets('enables and disables submit based on valid inputs', (
      WidgetTester tester,
    ) async {
      await _prepareViewport(tester);
      await tester.pumpWidget(_buildHomePage());

      expect(_submitButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '83702');
      await tester.pump();
      expect(_submitButton(tester).onPressed, isNull);

      await _selectSymptom(tester, 'C', 'Daily respiratory or asthma symptoms');
      expect(_submitButton(tester).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), '12@#');
      await tester.pump();
      expect(_submitButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Boise');
      await tester.pump();
      expect(_submitButton(tester).onPressed, isNotNull);
    });
  });
}

Widget _buildHomePage() {
  final localeNotifier = ValueNotifier<Locale?>(const Locale('en'));
  return MaterialApp(
    locale: localeNotifier.value,
    supportedLocales: LocaleService.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: HomePage(localeNotifier: localeNotifier),
  );
}

Future<void> _prepareViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

ElevatedButton _submitButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Get activity recommendation'),
  );
}

Future<void> _selectSymptom(
  WidgetTester tester,
  String id,
  String label,
) async {
  await _prepareViewport(tester);
  await tester.tap(find.text('Select symptom level'));
  await tester.pumpAndSettle();

  final labelFinder = find.text(label);
  await tester.scrollUntilVisible(
    labelFinder,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(labelFinder, warnIfMissed: false);
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm selection'));
  await tester.pumpAndSettle();

  expect(find.text('$id: $label'), findsOneWidget);
}