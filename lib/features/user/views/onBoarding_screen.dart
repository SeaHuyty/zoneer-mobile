import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_prefs.dart';
import 'package:zoneer_mobile/shared/widgets/google_nav_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('this is onborading screen'),
            ElevatedButton(
              onPressed: () => setState(() {
                AppPrefs.setOnboardingDone();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GoogleNavBar()),
                );
              }),
              child: Text('done'),
            ),
          ],
        ),
      ),
    );
  }
}
