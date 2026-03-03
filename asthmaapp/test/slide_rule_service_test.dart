import 'package:flutter_test/flutter_test.dart';
import 'package:asthmaapp/services/slide_rule_service.dart';
import 'package:asthmaapp/widgets/symptom_modal.dart';

void main() {
  group('SlideRuleService.getRecommendation', () {
    for (final color in AqiColor.values) {
      group('${color.name[0].toUpperCase()}${color.name.substring(1)}', () {
        int testCount = 0;
        final totalTests = ActivityLevel.values.length * SymptomLevel.values.length;
        for (final activity in ActivityLevel.values) {
          for (final symptom in SymptomLevel.values) {
            test('${color.name} - ${activity.name} - ${symptom.id}', () {
              final result = SlideRuleService.getRecommendation(
                aqiColor: color,
                activityLevel: activity,
                symptomLevel: symptom,
              );
              Recommendation expected = Recommendation.ok;
              if (color == AqiColor.maroon) {
                expected = Recommendation.nr;
              } else if (color == AqiColor.purple) {
                if (activity == ActivityLevel.moderate || activity == ActivityLevel.vigorous) {
                  expected = Recommendation.nr;
                } else if (activity == ActivityLevel.light) {
                  if (symptom == SymptomLevel.b || symptom == SymptomLevel.c) {
                    expected = Recommendation.nr;
                  } else {
                    expected = Recommendation.ok;
                  }
                }
              } else if (color == AqiColor.red) {
                if (activity == ActivityLevel.moderate || activity == ActivityLevel.vigorous) {
                  expected = Recommendation.nr;
                } else if (activity == ActivityLevel.light) {
                  if (symptom == SymptomLevel.c) {
                    expected = Recommendation.nr;
                  } else {
                    expected = Recommendation.ok;
                  }
                }
              } else if (color == AqiColor.orange || color == AqiColor.yellow) {
                if (activity == ActivityLevel.moderate && symptom == SymptomLevel.c) {
                  expected = Recommendation.nr;
                } else if (activity == ActivityLevel.vigorous && (symptom == SymptomLevel.b || symptom == SymptomLevel.c)) {
                  expected = Recommendation.nr;
                } else {
                  expected = Recommendation.ok;
                }
              } else if (color == AqiColor.green) {
                if (activity == ActivityLevel.vigorous && (symptom == SymptomLevel.b || symptom == SymptomLevel.c)) {
                  expected = Recommendation.nr;
                } else {
                  expected = Recommendation.ok;
                }
              }
              expect(result, expected);
              testCount++;
            });
          }
        }
        tearDownAll(() {
          if (testCount == totalTests) {
            print('All tests passed for ${color.name[0].toUpperCase()}${color.name.substring(1)}');
          }
        });
      });
    }
  });
}
    