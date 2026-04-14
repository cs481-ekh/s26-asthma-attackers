import 'package:asthmaapp/services/slide_rule_service.dart';
import 'package:asthmaapp/widgets/symptom_modal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlideRuleService.getRecommendation', () {
    test('covers the full AQI x activity x symptom matrix', () {
      final cases = <({
        AqiColor color,
        ActivityLevel activity,
        SymptomLevel symptom,
        Recommendation expected,
      })>[
        for (final color in AqiColor.values)
          for (final activity in ActivityLevel.values)
            for (final symptom in SymptomLevel.values)
              (
                color: color,
                activity: activity,
                symptom: symptom,
                expected: _expectedRecommendation(color, activity, symptom),
              ),
      ];

      expect(cases, hasLength(54));

      for (final testCase in cases) {
        expect(
          SlideRuleService.getRecommendation(
            aqiColor: testCase.color,
            activityLevel: testCase.activity,
            symptomLevel: testCase.symptom,
          ),
          testCase.expected,
          reason:
              'Unexpected recommendation for ${testCase.color.name} / ${testCase.activity.name} / ${testCase.symptom.id}',
        );
      }
    });
  });
}

Recommendation _expectedRecommendation(
  AqiColor color,
  ActivityLevel activity,
  SymptomLevel symptom,
) {
  switch (color) {
    case AqiColor.green:
      if (activity == ActivityLevel.vigorous && symptom != SymptomLevel.a) {
        return Recommendation.nr;
      }
      return Recommendation.ok;
    case AqiColor.yellow:
    case AqiColor.orange:
      if (activity == ActivityLevel.moderate && symptom == SymptomLevel.c) {
        return Recommendation.nr;
      }
      if (activity == ActivityLevel.vigorous && symptom != SymptomLevel.a) {
        return Recommendation.nr;
      }
      return Recommendation.ok;
    case AqiColor.red:
      if (activity == ActivityLevel.light && symptom != SymptomLevel.c) {
        return Recommendation.ok;
      }
      return Recommendation.nr;
    case AqiColor.purple:
      if (activity == ActivityLevel.light && symptom == SymptomLevel.a) {
        return Recommendation.ok;
      }
      return Recommendation.nr;
    case AqiColor.maroon:
      return Recommendation.nr;
  }
}

