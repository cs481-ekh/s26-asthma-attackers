// Basic Flutter widget test for Asthma Activity Advisor.

import 'package:flutter_test/flutter_test.dart';

import 'package:asthmaapp/main.dart';

void main() {
  testWidgets('App launches to home page with symptom and location inputs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsthmaActivityAdvisorApp());

    expect(find.text('Asthma Activity Advisor'), findsOneWidget);
    expect(find.text('Get activity recommendation'), findsOneWidget);
  });
}
