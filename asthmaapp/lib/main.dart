import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'pages/home_page.dart';
import 'pages/recommendation_page.dart';
import 'pages/about_page.dart';
import 'services/locale_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  await dotenv.load(isOptional: true);
  WidgetsFlutterBinding.ensureInitialized();
  final initialLocale = await LocaleService.load();
  runApp(AsthmaActivityAdvisorApp(initialLocale: initialLocale));
}

class AsthmaActivityAdvisorApp extends StatelessWidget {
  AsthmaActivityAdvisorApp({super.key, Locale? initialLocale})
    : localeNotifier = ValueNotifier<Locale?>(initialLocale);

  final ValueNotifier<Locale?> localeNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Asthma Activity Advisor',
          theme: AppTheme.lightThemeForLocale(locale),
          locale: locale,
          supportedLocales: LocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(localeNotifier: localeNotifier),
            RecommendationPage.routeName: (context) =>
                RecommendationPage(localeNotifier: localeNotifier),
            '/about': (context) => AboutPage(localeNotifier: localeNotifier),
          },
          onGenerateRoute: (settings) {
            if (settings.name == RecommendationPage.routeName) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (context) =>
                    RecommendationPage(localeNotifier: localeNotifier),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
