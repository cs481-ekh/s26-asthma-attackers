import 'package:asthmaapp/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('SymptomModal', () {
    for (final testCase in const [
      ('A', 'No respiratory or asthma symptoms'),
      ('B', 'Few respiratory or asthma symptoms'),
      ('C', 'Daily respiratory or asthma symptoms'),
    ]) {
      testWidgets('selecting ${testCase.$1} dismisses the modal and updates HomePage', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Select symptom level'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Select symptom level'), findsNWidgets(2));

        final labelFinder = find.text(testCase.$2);
        await tester.scrollUntilVisible(
          labelFinder,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(labelFinder, warnIfMissed: false);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm selection'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Confirm selection'), findsNothing);
        expect(find.text('${testCase.$1}: ${testCase.$2}'), findsOneWidget);
      });
    }
  });
}