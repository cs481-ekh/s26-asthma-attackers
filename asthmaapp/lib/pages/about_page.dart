import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sdp_sticker.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget sectionBody(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Overview
            sectionTitle("Asthma Activity Advisor"),
            sectionBody(
              "The Asthma Activity Advisor app guides users by asking about a child’s current symptoms, referencing real-time air pollution levels, and calculating recommended activity levels based on established health rules. This functionality helps reduce risk and provides peace of mind for families and youth-serving organizations.",
            ),

            // Objective
            sectionTitle("Objective"),
            sectionBody(
              "Air pollution—especially from wildfire smoke, traffic, and industrial emissions—can trigger severe asthma symptoms. Caregivers and educators often lack a simple, reliable way to assess when outdoor activity is safe. This app addresses that gap by delivering timely, evidence-based guidance to help prevent avoidable asthma attacks.\n\n"
              "Asthma is a chronic illness that affects many children. While it cannot be cured, it can be managed with the right information at the right time. This app is designed to be widely accessible and to support schools, families, and caregivers in keeping children safe and active.",
            ),

            // How it works
            sectionTitle("How It Works"),
            sectionBody(
              "The app digitizes a traditional asthma slide rule into a mobile and web application. It integrates real-time Air Quality Index (AQI) data with child respiratory health status and standardized physical activity guidelines.\n\n"
              "By combining these inputs, the app provides clear recommendations on appropriate activity levels under current air quality conditions.",
            ),

            // Inputs
            sectionTitle("Inputs"),
            sectionBody(
              "• Child respiratory health status (symptom level)\n"
              "• Air Quality Index (AQI)",
            ),

            // Output
            sectionTitle("Output"),
            sectionBody(
              "• Recommended activity levels (low, moderate, vigorous)",
            ),

            // Resources
            sectionTitle("Resources"),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _launchURL(
                "https://www.airnow.gov/?city=Boise&state=ID&country=USA",
              ),
              child: const Text(
                "AirNow AQI (Boise)",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _launchURL(
                "https://www.boisestate.edu/research-resilience/resources-hazards/air-quality-and-smoke/",
              ),
              child: const Text(
                "Boise State Air Quality & Smoke Resources",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Divider(),

            const SizedBox(height: 20),

            Center(
              child: SdpFooterSticker(),
            ),
          ],
        ),
      ),
    );
  }
}