import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'pages/home_page.dart';
import 'pages/recommendation_page.dart';

void main() {
  runApp(const AsthmaActivityAdvisorApp());
}

class AsthmaActivityAdvisorApp extends StatelessWidget {
  const AsthmaActivityAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asthma Activity Advisor',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        RecommendationPage.routeName: (context) => const RecommendationPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == RecommendationPage.routeName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => const RecommendationPage(),
          );
        }
        return null;
      },
    );
  }
}
