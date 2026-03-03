import 'package:flutter_test/flutter_test.dart';
import '../lib/services/slide_rule_service.dart';
import '../lib/widgets/symptom_modal.dart';

void main() {
  group('SlideRuleService.getRecommendation', () {
    test('GREEN AQI returns OK for all', () {
      expect(
        SlideRuleService.getRecommendation(
          aqiColor: AqiColor.green,
          activityLevel: ActivityLevel.light,
          symptomLevel: SymptomLevel.a,
        ),
        Recommendation.ok,
      );
    });

    test('YELLOW AQI returns correct for moderate activity, symptom C', () {
      expect(
        SlideRuleService.getRecommendation(
          aqiColor: AqiColor.yellow,
          activityLevel: ActivityLevel.moderate,
          symptomLevel: SymptomLevel.c,
        ),
        Recommendation.nr,
      );
    });

    test('ORANGE AQI returns NR for vigorous activity, symptom B', () {
      expect(
        SlideRuleService.getRecommendation(
          aqiColor: AqiColor.orange,
          activityLevel: ActivityLevel.vigorous,
          symptomLevel: SymptomLevel.b,
        ),
        Recommendation.nr,
      );
    });

    test('RED AQI returns NR for light activity, symptom A', () {
      expect(
        SlideRuleService.getRecommendation(
          aqiColor: AqiColor.red,
          activityLevel: ActivityLevel.light,
          symptomLevel: SymptomLevel.a,
        ),
        Recommendation.ok,
      );
    });

    test('PURPLE AQI returns NR for moderate activity, symptom C', () {
      expect(
        SlideRuleService.getRecommendation(
          aqiColor: AqiColor.purple,
          activityLevel: ActivityLevel.moderate,
          symptomLevel: SymptomLevel.c,
        ),
        Recommendation.nr,
      );
    });

    test('MAROON AQI returns NR for any', () {
      expect(
        SlideRuleService.getRecommendation(
          aqiColor: AqiColor.maroon,
          activityLevel: ActivityLevel.light,
          symptomLevel: SymptomLevel.a,
        ),
        Recommendation.nr,
      );
    });
  });
}
