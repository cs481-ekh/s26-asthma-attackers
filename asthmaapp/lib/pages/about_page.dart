import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sdp_sticker.dart';

import '../app_theme.dart';
import '../widgets/bottom_logos_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  
  Widget sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
      ),
    );
  }

  Widget sectionBody(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: AppTheme.textPrimary,
          ),
    );
  }

  Widget link(BuildContext context, {required String label, required String url}) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.linkColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomLogosBar(
        riLogoHeight: 104,
        soeWordmarkHeight: 72,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Go back',
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Overview
            sectionTitle(context, "Asthma Activity Advisor"),
            sectionBody(
              context,
              "The Asthma Activity Advisor app guides users by asking about a child’s current symptoms, referencing real-time air pollution levels, and calculating recommended activity levels based on established health rules. This functionality helps reduce risk and provides peace of mind for families and youth-serving organizations.",
            ),

            // Objective
            sectionTitle(context, "Objective"),
            sectionBody(
              context,
              "Air pollution—especially from wildfire smoke, traffic, and industrial emissions—can trigger severe asthma symptoms. Caregivers and educators often lack a simple, reliable way to assess when outdoor activity is safe. This app addresses that gap by delivering timely, evidence-based guidance to help prevent avoidable asthma attacks.\n\n"
              "Asthma is a chronic illness that affects many children. While it cannot be cured, it can be managed with the right information at the right time. This app is designed to be widely accessible and to support schools, families, and caregivers in keeping children safe and active.",
            ),

            // How it works
            sectionTitle(context, "How It Works"),
            sectionBody(
              context,
              "The app digitizes a traditional asthma slide rule into a mobile and web application. It integrates real-time Air Quality Index (AQI) data with child respiratory health status and standardized physical activity guidelines.\n\n"
              "By combining these inputs, the app provides clear recommendations on appropriate activity levels under current air quality conditions.",
            ),

            // Inputs
            sectionTitle(context, "Inputs"),
            sectionBody(
              context,
              "• Child respiratory health status (symptom level)\n"
              "• Air Quality Index (AQI)",
            ),

            // Output
            sectionTitle(context, "Output"),
            sectionBody(
              context,
              "• Recommended activity levels (low, moderate, vigorous)",
            ),

            sectionTitle("Understanding Air Quality and Health Risks"),
            sectionBody(
              "Air pollution occurs when pollutants such as smoke, vehicle exhaust, industrial emissions, and other airborne particles accumulate in the atmosphere. Under certain weather conditions—such as limited air movement or atmospheric layering—these pollutants can become trapped near the ground rather than dispersing into the upper atmosphere. When this happens, pollution levels increase and can create hazy or foggy conditions that reduce visibility and degrade air quality. These conditions may persist until weather patterns change and cleaner air can circulate and disperse the pollutants.\n\n"
              "Wildfire smoke can travel hundreds of miles downwind. Larger particles, such as ash, typically fall out closer to the fire. However, the smallest particles pose the greatest health risk and can travel the farthest. These tiny particles—known as PM2.5 (about 1/50 the size of a grain of sand)—can be inhaled deep into the air sacs of the lungs, where they can cause inflammation.\n\n"
              "Short-term exposure to smoke and other air pollutants can irritate the eyes, nose, and throat and may trigger coughing or breathing difficulties. Long-term exposure may contribute to lung damage and increase the risk of cardiovascular problems. People with pre-existing lung or respiratory conditions are especially vulnerable, although poor air quality can affect anyone."
            ),

            // Resources
            sectionTitle(context, "Resources"),
            const SizedBox(height: 8),

            link(
              context,
              label: "AirNow AQI (Boise)",
              url: "https://www.airnow.gov/?city=Boise&state=ID&country=USA",
            ),

            const SizedBox(height: 8),

            link(
              context,
              label: "Boise State Air Quality & Smoke Resources",
              url: "https://www.boisestate.edu/research-resilience/resources-hazards/air-quality-and-smoke/",
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // Contact
            // Contact Us
            sectionTitle("Contact Us"),
            sectionBody(
              "For any questions or more information, please contact the Boise State University Resilience Institute.",
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _launchURL(
                "https://www.boisestate.edu/research-resilience/",
              ),
              child: const Text(
                "Boise State Resilience Institute",
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