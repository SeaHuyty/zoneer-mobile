import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_prefs.dart';
import 'package:zoneer_mobile/shared/widgets/google_nav_bar.dart';
import '../../../core/utils/app_colors.dart';
import './onBoardingTab/onBoarding1.dart';
import './onBoardingTab/onBoarding2.dart';
import './onBoardingTab/onBoarding3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      AppPrefs.setOnboardingDone();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GoogleNavBar()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextButton(
              onPressed: () {
                AppPrefs.setOnboardingDone();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GoogleNavBar()),
                );
              },
              child: Text('Skip', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: 1),

              Expanded(
                flex: 7,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [Onboarding1(), Onboarding2(), Onboarding3()],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  bool isActive = _currentPage == index;
                  return Container(
                    margin: EdgeInsets.all(2),
                    width: isActive ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              Spacer(flex: 2),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == 2 ? "Get Started" : "Next",
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
