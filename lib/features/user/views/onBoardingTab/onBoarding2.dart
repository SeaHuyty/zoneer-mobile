import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import 'package:lottie/lottie.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

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
'assets/stickers/ZoneerOnboarding2.json'),
              ),
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    Text(
                      'Fast sell your property in just one click',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Simplify the property sales process with just your smartphone',
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