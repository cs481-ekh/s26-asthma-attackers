// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Asthma Activity Advisor';

  @override
  String get menuAbout => 'About';

  @override
  String get menuLanguage => 'Language';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get actionClose => 'Close';

  @override
  String get asthmaInfoTitle => 'Asthma Information';

  @override
  String get asthmaSymptomsTitle => 'Asthma Symptoms';

  @override
  String get asthmaSymptomBullet1 => 'Chronic (regular) cough';

  @override
  String get asthmaSymptomBullet2 => 'Wheezing';

  @override
  String get asthmaSymptomBullet3 => 'Shortness of breath';

  @override
  String get asthmaSymptomBullet4 => 'Tightness in the chest';

  @override
  String get asthmaSymptomBullet5 => 'Breathing difficulties';

  @override
  String get asthmaSymptomBullet6 => 'Trouble sleeping';

  @override
  String get asthmaSymptomBullet7 =>
      'Trouble participating in physical activities';

  @override
  String get asthmaTriggersTitle => 'Asthma Triggers';

  @override
  String get asthmaTriggerBullet1 => 'Infections of the ear and nose';

  @override
  String get asthmaTriggerBullet2 => 'Infections of the sinuses';

  @override
  String get asthmaTriggerBullet3 => 'Air pollution';

  @override
  String get asthmaTriggerBullet4 => 'Cigarette smoke';

  @override
  String get asthmaTriggerBullet5 => 'Cold air, Dry air, Pollens';

  @override
  String get asthmaTriggerBullet6 => 'Dust, Mites, Molds';

  @override
  String get asthmaTriggerBullet7 => 'Vigorous exercise';

  @override
  String get asthmaTriggerBullet8 => 'Psychological stress';

  @override
  String get actionChange => 'Change';

  @override
  String get actionRetry => 'Retry';

  @override
  String get homeHeroTitle => 'An app for asthma warriors';

  @override
  String get homeHeroSubtitle =>
      'Check air quality and get activity ideas that fit how your child feels today.';

  @override
  String get symptomLevelTitle => 'Child\'s symptom level';

  @override
  String get selectSymptomLevel => 'Select symptom level';

  @override
  String get symptomSelectTitle => 'Select symptom level';

  @override
  String get symptomSelectSubtitle =>
      'Choose the option that best describes the child\'s current respiratory or asthma symptoms.';

  @override
  String get confirmSelection => 'Confirm selection';

  @override
  String get locationTitle => 'Location for air quality';

  @override
  String get locationHelperWeb =>
      'Enter a ZIP code or city name (required on web). ';

  @override
  String get locationHelperMobile =>
      'Use your device location or enter a ZIP code or city. ';

  @override
  String get moreDetails => 'More details';

  @override
  String get usingYourLocation => 'Using your location';

  @override
  String get zipOrCityLabel => 'ZIP code or city';

  @override
  String get zipOrCityHint => 'e.g. 83702 or Boise';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get gettingLocation => 'Getting location…';

  @override
  String get getRecommendation => 'Get activity recommendation';

  @override
  String get snackSelectSymptomFirst => 'Please select a symptom level first.';

  @override
  String get snackEnterZipOrCityWeb =>
      'Enter a ZIP code or city name to get air quality.';

  @override
  String get snackEnterZipOrCityMobile =>
      'Use \"Use my location\" or enter a ZIP code or city to get air quality.';

  @override
  String get aboutTitle => 'About';

  @override
  String get recommendationTitle => 'Activity recommendation';

  @override
  String get goBack => 'Go back';

  @override
  String get currentLocation => 'Current location';

  @override
  String get loadingLocation => 'Loading location';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Enable them in device settings.';

  @override
  String get locationPermissionDenied =>
      'Location permission was denied. Enter a ZIP code or city instead.';

  @override
  String get locationPermissionDeniedForever =>
      'Location is permanently denied. Enter a ZIP code or city instead.';

  @override
  String get locationFetchFailed =>
      'Could not get location. Try again or enter a ZIP code or city.';

  @override
  String get validationEnterZipOrCity => 'Enter a ZIP code or city name.';

  @override
  String get validationInvalidZipOrCity =>
      'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).';

  @override
  String get symptomALabel => 'No respiratory or asthma symptoms';

  @override
  String get symptomBLabel => 'Few respiratory or asthma symptoms';

  @override
  String get symptomCLabel => 'Daily respiratory or asthma symptoms';

  @override
  String get symptomADescription =>
      'Child has no breathing issues or asthma symptoms.';

  @override
  String get symptomBDescription => 'Child has mild or occasional symptoms.';

  @override
  String get symptomCDescription =>
      'Child has symptoms most days or more severe symptoms.';

  @override
  String get aboutOverviewBody =>
      'The Asthma Activity Advisor app guides users by asking about a child’s current symptoms, referencing real-time air pollution levels, and calculating recommended activity levels based on established health rules. This functionality helps reduce risk and provides peace of mind for families and youth-serving organizations.';

  @override
  String get aboutObjectiveTitle => 'Objective';

  @override
  String get aboutObjectiveBody =>
      'Air pollution-especially from wildfire smoke, traffic, and industrial emissions-can trigger severe asthma symptoms. Caregivers and educators often lack a simple, reliable way to assess when outdoor activity is safe. This app addresses that gap by delivering timely, evidence-based guidance to help prevent avoidable asthma attacks.\n\nAsthma is a chronic illness that affects many children. While it cannot be cured, it can be managed with the right information at the right time. This app is designed to be widely accessible and to support schools, families, and caregivers in keeping children safe and active.';

  @override
  String get aboutHowItWorksTitle => 'How It Works';

  @override
  String get aboutHowItWorksBody =>
      'The app digitizes a traditional asthma slide rule into a mobile and web application. It integrates real-time Air Quality Index (AQI) data with child respiratory health status and standardized physical activity guidelines.\n\nBy combining these inputs, the app provides clear recommendations on appropriate activity levels under current air quality conditions.';

  @override
  String get aboutInputsTitle => 'Inputs';

  @override
  String get aboutInputsBody =>
      '• Child respiratory health status (symptom level)\n• Air Quality Index (AQI)';

  @override
  String get aboutOutputTitle => 'Output';

  @override
  String get aboutOutputBody =>
      '• Recommended activity levels (low, moderate, vigorous)';

  @override
  String get aboutAirQualityRisksTitle =>
      'Understanding Air Quality and Health Risks';

  @override
  String get aboutAirQualityRisksBody =>
      'Air pollution occurs when pollutants such as smoke, vehicle exhaust, industrial emissions, and other airborne particles accumulate in the atmosphere. Under certain weather conditions-such as limited air movement or atmospheric layering-these pollutants can become trapped near the ground rather than dispersing into the upper atmosphere. When this happens, pollution levels increase and can create hazy or foggy conditions that reduce visibility and degrade air quality. These conditions may persist until weather patterns change and cleaner air can circulate and disperse the pollutants.\n\nWildfire smoke can travel hundreds of miles downwind. Larger particles, such as ash, typically fall out closer to the fire. However, the smallest particles pose the greatest health risk and can travel the farthest. These tiny particles-known as PM2.5 (about 1/50 the size of a grain of sand)-can be inhaled deep into the air sacs of the lungs, where they can cause inflammation.\n\nShort-term exposure to smoke and other air pollutants can irritate the eyes, nose, and throat and may trigger coughing or breathing difficulties. Long-term exposure may contribute to lung damage and increase the risk of cardiovascular problems. People with pre-existing lung or respiratory conditions are especially vulnerable, although poor air quality can affect anyone.';

  @override
  String get aboutResourcesTitle => 'Resources';

  @override
  String get aboutResourceAirNow => 'AirNow AQI (Boise)';

  @override
  String get aboutResourceBsuAirQuality =>
      'Boise State Air Quality & Smoke Resources';

  @override
  String get aboutContactTitle => 'Contact Us';

  @override
  String get aboutContactBody =>
      'For any questions or more information, please contact the Boise State University Resilience Institute.';

  @override
  String get aboutResourceBsuResilienceInstitute =>
      'Boise State Resilience Institute';

  @override
  String get recommendationMissingLocationMessage =>
      'Please use \"Use my location\" or enter a ZIP code or city on the home screen to see air quality.';

  @override
  String get recommendationNoLocationProvided =>
      'No location provided. Use \"Use my location\" or enter a ZIP or city.';

  @override
  String get nextDayGuidanceButton => 'View next-day activity guidance';

  @override
  String get nextDayGuidanceTitle => 'Next-day activity guidance';

  @override
  String get nextDayGuidanceSubtitle =>
      'Forecast-based recommendation for tomorrow.';

  @override
  String get loadingNextDayForecast => 'Loading next-day forecast';

  @override
  String forecastAqiLabel(Object aqi, Object category) {
    return 'Forecast AQI: $aqi ($category)';
  }

  @override
  String locationLabelValue(Object location) {
    return 'Location: $location';
  }

  @override
  String get airQualityTitle => 'Air quality';

  @override
  String get loadingAirQuality => 'Loading air quality';

  @override
  String get loadingAirQualityEllipsis => 'Loading air quality…';

  @override
  String get enterLocationForAqi => 'Enter location on home to see AQI';

  @override
  String aqiLabelValue(Object aqi, Object category) {
    return 'AQI: $aqi  •  $category';
  }

  @override
  String updatedRelative(Object relative) {
    return 'Updated $relative';
  }

  @override
  String lastKnownAqi(Object aqi, Object category) {
    return 'Last known: AQI $aqi ($category)';
  }

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeMinutesAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String relativeHoursAgo(Object hours) {
    return '$hours hr ago';
  }

  @override
  String relativeDaysAgo(Object days) {
    return '$days day(s) ago';
  }

  @override
  String activityLoading(Object label) {
    return '$label: loading...';
  }

  @override
  String get activityRecommended => 'Recommended';

  @override
  String get activityNotRecommended => 'Not recommended';

  @override
  String get recommendedActivityTitle => 'Recommended activity';

  @override
  String get recommendationPendingMessage =>
      'Recommendation will appear here once AQI is available.';

  @override
  String get lightActivity => 'Light activity';

  @override
  String get mediumActivity => 'Medium activity';

  @override
  String get vigorousActivity => 'Vigorous activity';

  @override
  String get activityExamplesTitle => 'Activity examples';

  @override
  String get exampleLight1 => 'Walking slowly on level ground';

  @override
  String get exampleLight2 => 'Sitting in chair, standing';

  @override
  String get exampleLight3 => 'Using computer';

  @override
  String get exampleLight4 => 'Writing on paper or black board';

  @override
  String get exampleLight5 => 'Cooking, eating, drinking';

  @override
  String get exampleLight6 => 'Playing musical instruments';

  @override
  String get exampleLight7 => 'Carrying school books';

  @override
  String get exampleModerate1 => 'Playing badminton';

  @override
  String get exampleModerate2 => 'Skateboarding';

  @override
  String get exampleModerate3 => 'Aerobic dancing';

  @override
  String get exampleModerate4 => 'Competitive table tennis';

  @override
  String get exampleModerate5 => 'Softball - slow pitch';

  @override
  String get exampleModerate6 => 'Shooting basketballs';

  @override
  String get exampleModerate7 => 'Outdoor carpentry';

  @override
  String get exampleVigorous1 => 'Running, jogging';

  @override
  String get exampleVigorous2 => 'Performing jumping jacks';

  @override
  String get exampleVigorous3 => 'Football, Soccer, Baseball';

  @override
  String get exampleVigorous4 => 'Competitive swimming';

  @override
  String get exampleVigorous5 => 'Ice hockey, Water polo';

  @override
  String get exampleVigorous6 => 'Racquetball, Squash';

  @override
  String get explanationPending =>
      'Explanation will appear here after you get a recommendation.';

  @override
  String get explanationGreen =>
      'Air quality is good. Most people, even with symptoms, can safely perform outdoor activities.';

  @override
  String get explanationYellow =>
      'Air quality is acceptable. Sensitive individuals may experience mild symptoms, so consider limited prolonged exertion.';

  @override
  String get explanationOrange =>
      'Air quality is unhealthy for sensitive groups. Symptoms may worsen, so reduce outdoor activity intensity and duration.';

  @override
  String get explanationRed =>
      'Air quality is unhealthy. It is recommended to avoid strenuous outdoor activities, especially if experiencing symptoms.';

  @override
  String get explanationPurple =>
      'Air quality is very unhealthy. Outdoor activities should be avoided due to high risk of symptom aggravation.';

  @override
  String get explanationUnknown => 'Unable to determine recommendation';

  @override
  String get whyRecommendationTitle => 'Why this recommendation';

  @override
  String get moreInformation => 'More information';

  @override
  String get disclaimerText =>
      'This app is a guidance tool only and is not a substitute for professional medical advice. It does not diagnose asthma or any medical condition and does not provide emergency medical guidance.';

  @override
  String get noNextDayForecastMessage =>
      'Next-day forecast isn\'t available yet for this location. Try again later.';
}
