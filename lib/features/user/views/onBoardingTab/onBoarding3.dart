import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import 'package:lottie/lottie.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: 1),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Lottie.asset(
                  'assets/stickers/ZoneerOnboarding3.json'
                  ),

              ),
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    Text(
                      'Find your dream home with us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Just search and select your favorite property you want to locate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
  }
}