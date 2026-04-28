import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Asthma Activity Advisor'**
  String get appName;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'An app for asthma warriors'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check air quality and get activity ideas that fit how your child feels today.'**
  String get homeHeroSubtitle;

  /// No description provided for @symptomLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Child\'s symptom level'**
  String get symptomLevelTitle;

  /// No description provided for @selectSymptomLevel.
  ///
  /// In en, this message translates to:
  /// **'Select symptom level'**
  String get selectSymptomLevel;

  /// No description provided for @symptomSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select symptom level'**
  String get symptomSelectTitle;

  /// No description provided for @symptomSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the option that best describes the child\'s current respiratory or asthma symptoms.'**
  String get symptomSelectSubtitle;

  /// No description provided for @confirmSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm selection'**
  String get confirmSelection;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location for air quality'**
  String get locationTitle;

  /// No description provided for @locationHelperWeb.
  ///
  /// In en, this message translates to:
  /// **'Enter a ZIP code or city name (required on web). '**
  String get locationHelperWeb;

  /// No description provided for @locationHelperMobile.
  ///
  /// In en, this message translates to:
  /// **'Use your device location or enter a ZIP code or city. '**
  String get locationHelperMobile;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @usingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Using your location'**
  String get usingYourLocation;

  /// No description provided for @zipOrCityLabel.
  ///
  /// In en, this message translates to:
  /// **'ZIP code or city'**
  String get zipOrCityLabel;

  /// No description provided for @zipOrCityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 83702 or Boise'**
  String get zipOrCityHint;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location…'**
  String get gettingLocation;

  /// No description provided for @getRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Get activity recommendation'**
  String get getRecommendation;

  /// No description provided for @snackSelectSymptomFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a symptom level first.'**
  String get snackSelectSymptomFirst;

  /// No description provided for @snackEnterZipOrCityWeb.
  ///
  /// In en, this message translates to:
  /// **'Enter a ZIP code or city name to get air quality.'**
  String get snackEnterZipOrCityWeb;

  /// No description provided for @snackEnterZipOrCityMobile.
  ///
  /// In en, this message translates to:
  /// **'Use \"Use my location\" or enter a ZIP code or city to get air quality.'**
  String get snackEnterZipOrCityMobile;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @recommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity recommendation'**
  String get recommendationTitle;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @loadingLocation.
  ///
  /// In en, this message translates to:
  /// **'Loading location'**
  String get loadingLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Enable them in device settings.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Enter a ZIP code or city instead.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is permanently denied. Enter a ZIP code or city instead.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get location. Try again or enter a ZIP code or city.'**
  String get locationFetchFailed;

  /// No description provided for @validationEnterZipOrCity.
  ///
  /// In en, this message translates to:
  /// **'Enter a ZIP code or city name.'**
  String get validationEnterZipOrCity;

  /// No description provided for @validationInvalidZipOrCity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).'**
  String get validationInvalidZipOrCity;

  /// No description provided for @symptomALabel.
  ///
  /// In en, this message translates to:
  /// **'No respiratory or asthma symptoms'**
  String get symptomALabel;

  /// No description provided for @symptomBLabel.
  ///
  /// In en, this message translates to:
  /// **'Few respiratory or asthma symptoms'**
  String get symptomBLabel;

  /// No description provided for @symptomCLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily respiratory or asthma symptoms'**
  String get symptomCLabel;

  /// No description provided for @symptomADescription.
  ///
  /// In en, this message translates to:
  /// **'Child has no breathing issues or asthma symptoms.'**
  String get symptomADescription;

  /// No description provided for @symptomBDescription.
  ///
  /// In en, this message translates to:
  /// **'Child has mild or occasional symptoms.'**
  String get symptomBDescription;

  /// No description provided for @symptomCDescription.
  ///
  /// In en, this message translates to:
  /// **'Child has symptoms most days or more severe symptoms.'**
  String get symptomCDescription;

  /// No description provided for @aboutOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'The Asthma Activity Advisor app guides users by asking about a child’s current symptoms, referencing real-time air pollution levels, and calculating recommended activity levels based on established health rules. This functionality helps reduce risk and provides peace of mind for families and youth-serving organizations.'**
  String get aboutOverviewBody;

  /// No description provided for @aboutObjectiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get aboutObjectiveTitle;

  /// No description provided for @aboutObjectiveBody.
  ///
  /// In en, this message translates to:
  /// **'Air pollution-especially from wildfire smoke, traffic, and industrial emissions-can trigger severe asthma symptoms. Caregivers and educators often lack a simple, reliable way to assess when outdoor activity is safe. This app addresses that gap by delivering timely, evidence-based guidance to help prevent avoidable asthma attacks.\n\nAsthma is a chronic illness that affects many children. While it cannot be cured, it can be managed with the right information at the right time. This app is designed to be widely accessible and to support schools, families, and caregivers in keeping children safe and active.'**
  String get aboutObjectiveBody;

  /// No description provided for @aboutHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get aboutHowItWorksTitle;

  /// No description provided for @aboutHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'The app digitizes a traditional asthma slide rule into a mobile and web application. It integrates real-time Air Quality Index (AQI) data with child respiratory health status and standardized physical activity guidelines.\n\nBy combining these inputs, the app provides clear recommendations on appropriate activity levels under current air quality conditions.'**
  String get aboutHowItWorksBody;

  /// No description provided for @aboutInputsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get aboutInputsTitle;

  /// No description provided for @aboutInputsBody.
  ///
  /// In en, this message translates to:
  /// **'• Child respiratory health status (symptom level)\n• Air Quality Index (AQI)'**
  String get aboutInputsBody;

  /// No description provided for @aboutOutputTitle.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get aboutOutputTitle;

  /// No description provided for @aboutOutputBody.
  ///
  /// In en, this message translates to:
  /// **'• Recommended activity levels (low, moderate, vigorous)'**
  String get aboutOutputBody;

  /// No description provided for @aboutAirQualityRisksTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding Air Quality and Health Risks'**
  String get aboutAirQualityRisksTitle;

  /// No description provided for @aboutAirQualityRisksBody.
  ///
  /// In en, this message translates to:
  /// **'Air pollution occurs when pollutants such as smoke, vehicle exhaust, industrial emissions, and other airborne particles accumulate in the atmosphere. Under certain weather conditions-such as limited air movement or atmospheric layering-these pollutants can become trapped near the ground rather than dispersing into the upper atmosphere. When this happens, pollution levels increase and can create hazy or foggy conditions that reduce visibility and degrade air quality. These conditions may persist until weather patterns change and cleaner air can circulate and disperse the pollutants.\n\nWildfire smoke can travel hundreds of miles downwind. Larger particles, such as ash, typically fall out closer to the fire. However, the smallest particles pose the greatest health risk and can travel the farthest. These tiny particles-known as PM2.5 (about 1/50 the size of a grain of sand)-can be inhaled deep into the air sacs of the lungs, where they can cause inflammation.\n\nShort-term exposure to smoke and other air pollutants can irritate the eyes, nose, and throat and may trigger coughing or breathing difficulties. Long-term exposure may contribute to lung damage and increase the risk of cardiovascular problems. People with pre-existing lung or respiratory conditions are especially vulnerable, although poor air quality can affect anyone.'**
  String get aboutAirQualityRisksBody;

  /// No description provided for @aboutResourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get aboutResourcesTitle;

  /// No description provided for @aboutResourceAirNow.
  ///
  /// In en, this message translates to:
  /// **'AirNow AQI (Boise)'**
  String get aboutResourceAirNow;

  /// No description provided for @aboutResourceBsuAirQuality.
  ///
  /// In en, this message translates to:
  /// **'Boise State Air Quality & Smoke Resources'**
  String get aboutResourceBsuAirQuality;

  /// No description provided for @aboutContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get aboutContactTitle;

  /// No description provided for @aboutContactBody.
  ///
  /// In en, this message translates to:
  /// **'For any questions or more information, please contact the Boise State University Resilience Institute.'**
  String get aboutContactBody;

  /// No description provided for @aboutResourceBsuResilienceInstitute.
  ///
  /// In en, this message translates to:
  /// **'Boise State Resilience Institute'**
  String get aboutResourceBsuResilienceInstitute;

  /// No description provided for @recommendationMissingLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please use \"Use my location\" or enter a ZIP code or city on the home screen to see air quality.'**
  String get recommendationMissingLocationMessage;

  /// No description provided for @recommendationNoLocationProvided.
  ///
  /// In en, this message translates to:
  /// **'No location provided. Use \"Use my location\" or enter a ZIP or city.'**
  String get recommendationNoLocationProvided;

  /// No description provided for @nextDayGuidanceButton.
  ///
  /// In en, this message translates to:
  /// **'View next-day activity guidance'**
  String get nextDayGuidanceButton;

  /// No description provided for @nextDayGuidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Next-day activity guidance'**
  String get nextDayGuidanceTitle;

  /// No description provided for @nextDayGuidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast-based recommendation for tomorrow.'**
  String get nextDayGuidanceSubtitle;

  /// No description provided for @loadingNextDayForecast.
  ///
  /// In en, this message translates to:
  /// **'Loading next-day forecast'**
  String get loadingNextDayForecast;

  /// No description provided for @forecastAqiLabel.
  ///
  /// In en, this message translates to:
  /// **'Forecast AQI: {aqi} ({category})'**
  String forecastAqiLabel(Object aqi, Object category);

  /// No description provided for @locationLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String locationLabelValue(Object location);

  /// No description provided for @airQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Air quality'**
  String get airQualityTitle;

  /// No description provided for @loadingAirQuality.
  ///
  /// In en, this message translates to:
  /// **'Loading air quality'**
  String get loadingAirQuality;

  /// No description provided for @loadingAirQualityEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading air quality…'**
  String get loadingAirQualityEllipsis;

  /// No description provided for @enterLocationForAqi.
  ///
  /// In en, this message translates to:
  /// **'Enter location on home to see AQI'**
  String get enterLocationForAqi;

  /// No description provided for @aqiLabelValue.
  ///
  /// In en, this message translates to:
  /// **'AQI: {aqi}  •  {category}'**
  String aqiLabelValue(Object aqi, Object category);

  /// No description provided for @updatedRelative.
  ///
  /// In en, this message translates to:
  /// **'Updated {relative}'**
  String updatedRelative(Object relative);

  /// No description provided for @lastKnownAqi.
  ///
  /// In en, this message translates to:
  /// **'Last known: AQI {aqi} ({category})'**
  String lastKnownAqi(Object aqi, Object category);

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String relativeMinutesAgo(Object minutes);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String relativeHoursAgo(Object hours);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) ago'**
  String relativeDaysAgo(Object days);

  /// No description provided for @activityLoading.
  ///
  /// In en, this message translates to:
  /// **'{label}: loading...'**
  String activityLoading(Object label);

  /// No description provided for @activityRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get activityRecommended;

  /// No description provided for @activityNotRecommended.
  ///
  /// In en, this message translates to:
  /// **'Not recommended'**
  String get activityNotRecommended;

  /// No description provided for @recommendedActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended activity'**
  String get recommendedActivityTitle;

  /// No description provided for @recommendationPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Recommendation will appear here once AQI is available.'**
  String get recommendationPendingMessage;

  /// No description provided for @lightActivity.
  ///
  /// In en, this message translates to:
  /// **'Light activity'**
  String get lightActivity;

  /// No description provided for @mediumActivity.
  ///
  /// In en, this message translates to:
  /// **'Medium activity'**
  String get mediumActivity;

  /// No description provided for @vigorousActivity.
  ///
  /// In en, this message translates to:
  /// **'Vigorous activity'**
  String get vigorousActivity;

  /// No description provided for @activityExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity examples'**
  String get activityExamplesTitle;

  /// No description provided for @exampleLight1.
  ///
  /// In en, this message translates to:
  /// **'Walking slowly on level ground'**
  String get exampleLight1;

  /// No description provided for @exampleLight2.
  ///
  /// In en, this message translates to:
  /// **'Sitting in chair, standing'**
  String get exampleLight2;

  /// No description provided for @exampleLight3.
  ///
  /// In en, this message translates to:
  /// **'Using computer'**
  String get exampleLight3;

  /// No description provided for @exampleLight4.
  ///
  /// In en, this message translates to:
  /// **'Writing on paper or black board'**
  String get exampleLight4;

  /// No description provided for @exampleLight5.
  ///
  /// In en, this message translates to:
  /// **'Cooking, eating, drinking'**
  String get exampleLight5;

  /// No description provided for @exampleLight6.
  ///
  /// In en, this message translates to:
  /// **'Playing musical instruments'**
  String get exampleLight6;

  /// No description provided for @exampleLight7.
  ///
  /// In en, this message translates to:
  /// **'Carrying school books'**
  String get exampleLight7;

  /// No description provided for @exampleModerate1.
  ///
  /// In en, this message translates to:
  /// **'Playing badminton'**
  String get exampleModerate1;

  /// No description provided for @exampleModerate2.
  ///
  /// In en, this message translates to:
  /// **'Skateboarding'**
  String get exampleModerate2;

  /// No description provided for @exampleModerate3.
  ///
  /// In en, this message translates to:
  /// **'Aerobic dancing'**
  String get exampleModerate3;

  /// No description provided for @exampleModerate4.
  ///
  /// In en, this message translates to:
  /// **'Competitive table tennis'**
  String get exampleModerate4;

  /// No description provided for @exampleModerate5.
  ///
  /// In en, this message translates to:
  /// **'Softball - slow pitch'**
  String get exampleModerate5;

  /// No description provided for @exampleModerate6.
  ///
  /// In en, this message translates to:
  /// **'Shooting basketballs'**
  String get exampleModerate6;

  /// No description provided for @exampleModerate7.
  ///
  /// In en, this message translates to:
  /// **'Outdoor carpentry'**
  String get exampleModerate7;

  /// No description provided for @exampleVigorous1.
  ///
  /// In en, this message translates to:
  /// **'Running, jogging'**
  String get exampleVigorous1;

  /// No description provided for @exampleVigorous2.
  ///
  /// In en, this message translates to:
  /// **'Performing jumping jacks'**
  String get exampleVigorous2;

  /// No description provided for @exampleVigorous3.
  ///
  /// In en, this message translates to:
  /// **'Football, Soccer, Baseball'**
  String get exampleVigorous3;

  /// No description provided for @exampleVigorous4.
  ///
  /// In en, this message translates to:
  /// **'Competitive swimming'**
  String get exampleVigorous4;

  /// No description provided for @exampleVigorous5.
  ///
  /// In en, this message translates to:
  /// **'Ice hockey, Water polo'**
  String get exampleVigorous5;

  /// No description provided for @exampleVigorous6.
  ///
  /// In en, this message translates to:
  /// **'Racquetball, Squash'**
  String get exampleVigorous6;

  /// No description provided for @explanationPending.
  ///
  /// In en, this message translates to:
  /// **'Explanation will appear here after you get a recommendation.'**
  String get explanationPending;

  /// No description provided for @explanationGreen.
  ///
  /// In en, this message translates to:
  /// **'Air quality is good. Most people, even with symptoms, can safely perform outdoor activities.'**
  String get explanationGreen;

  /// No description provided for @explanationYellow.
  ///
  /// In en, this message translates to:
  /// **'Air quality is acceptable. Sensitive individuals may experience mild symptoms, so consider limited prolonged exertion.'**
  String get explanationYellow;

  /// No description provided for @explanationOrange.
  ///
  /// In en, this message translates to:
  /// **'Air quality is unhealthy for sensitive groups. Symptoms may worsen, so reduce outdoor activity intensity and duration.'**
  String get explanationOrange;

  /// No description provided for @explanationRed.
  ///
  /// In en, this message translates to:
  /// **'Air quality is unhealthy. It is recommended to avoid strenuous outdoor activities, especially if experiencing symptoms.'**
  String get explanationRed;

  /// No description provided for @explanationPurple.
  ///
  /// In en, this message translates to:
  /// **'Air quality is very unhealthy. Outdoor activities should be avoided due to high risk of symptom aggravation.'**
  String get explanationPurple;

  /// No description provided for @explanationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine recommendation'**
  String get explanationUnknown;

  /// No description provided for @whyRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this recommendation'**
  String get whyRecommendationTitle;

  /// No description provided for @moreInformation.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get moreInformation;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This app is a guidance tool only and is not a substitute for professional medical advice. It does not diagnose asthma or any medical condition and does not provide emergency medical guidance.'**
  String get disclaimerText;

  /// No description provided for @noNextDayForecastMessage.
  ///
  /// In en, this message translates to:
  /// **'Next-day forecast isn\'t available yet for this location. Try again later.'**
  String get noNextDayForecastMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
