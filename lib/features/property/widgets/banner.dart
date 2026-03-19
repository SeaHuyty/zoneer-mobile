import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';

class BannerZoneer extends StatelessWidget {
  const BannerZoneer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Text & Button
            Container(
              width: MediaQuery.of(context).size.width * 0.55, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover your perfect place to stay today.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Browse your favorite property.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.background,
                    ),
                  ),
                  SizedBox(height: 5),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.contrast,
                      foregroundColor: AppColors.black,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Browse Now!',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
      
            // Mascot image positioned to the right
            Positioned(
              right: 0,
              bottom: -25,
              child: Image.asset('assets/images/Zoneer_mascot.png', height: 120),
            ),
          ],
        ),
      ),
    );
  }
}
