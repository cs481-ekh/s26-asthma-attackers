import '../widgets/symptom_modal.dart';

/// Slide Rule Decision Matrix API
/// Returns recommendation (OK/NR) based on AQI color, activity level, and symptom level.
/// Import SymptomLevel from symptom_modal.dart

enum AqiColor {
  green,
  yellow,
  orange,
  red,
  purple,
  maroon,
}

enum ActivityLevel {
  light,
  moderate,
  vigorous,
}

enum Recommendation {
  ok,
  nr,
}


class SlideRuleService {
  // Example decision matrix (partial, fill in with real logic)
  static Recommendation getRecommendation({
    required AqiColor aqiColor,
    required ActivityLevel activityLevel,
    required SymptomLevel symptomLevel,
  }) {
    // Green AQI Logic
    if (aqiColor == AqiColor.green) {
      if (activityLevel == ActivityLevel.vigorous) {
        if (symptomLevel == SymptomLevel.a) {
          return Recommendation.ok;
        }
        return Recommendation.nr;
      }
      return Recommendation.ok;
    }

    // Yellow AQI Logic
    if (aqiColor == AqiColor.yellow) {
      if (activityLevel == ActivityLevel.light) {
        return Recommendation.ok;
      } else if (activityLevel == ActivityLevel.moderate) {
        if (symptomLevel == SymptomLevel.c) {
          return Recommendation.nr;
        }
        return Recommendation.ok;
      } else if (activityLevel == ActivityLevel.vigorous) {
        if (symptomLevel == SymptomLevel.a) {
          return Recommendation.ok;
        }
        return Recommendation.nr;
      }
    }

    // Orange AQI Logic
    if (aqiColor == AqiColor.orange) {
      if (activityLevel == ActivityLevel.light) {
        return Recommendation.ok;
      } else if (activityLevel == ActivityLevel.moderate) {
        if (symptomLevel == SymptomLevel.c) {
          return Recommendation.nr;
        }
        return Recommendation.ok;
      } else if (activityLevel == ActivityLevel.vigorous) {
        if (symptomLevel == SymptomLevel.a) {
          return Recommendation.ok;
        }
        return Recommendation.nr;
      }
    }

    // Red AQI Logic
    if (aqiColor == AqiColor.red) {
      if (activityLevel == ActivityLevel.light) {
        if (symptomLevel == SymptomLevel.c) {
          return Recommendation.nr;
        }
        return Recommendation.ok;
      } 
      return Recommendation.nr;
    }

    // Purple AQI Logic
    if (aqiColor == AqiColor.purple) {
      if (activityLevel == ActivityLevel.light) {
        if (symptomLevel == SymptomLevel.a) {
          return Recommendation.ok;
        }
        return Recommendation.nr;
      } 
      return Recommendation.nr;
    }

    // Maroon AQI Logic
    if (aqiColor == AqiColor.maroon) {
      return Recommendation.nr;
    }

    // Default fallback
    return Recommendation.ok;
  }
}

AqiColor mapAqiCategory(String category) {
  switch (category.toLowerCase()) {
    case 'good':
      return AqiColor.green;

    case 'moderate':
      return AqiColor.yellow;

    case 'unhealthy for sensitive groups':
      return AqiColor.orange;

    case 'unhealthy':
      return AqiColor.red;

    case 'very unhealthy':
      return AqiColor.purple;

    case 'hazardous':
      return AqiColor.maroon;

    default:
      return AqiColor.yellow;
  }
}

//final result = SlideRuleService.getRecommendation(
//   aqiColor: AqiColor.yellow, // or the AQI color you get from your logic
//   activityLevel: ActivityLevel.light, // or the user’s chosen activity level
//   symptomLevel: selectedSymptom, // from your input
// );
