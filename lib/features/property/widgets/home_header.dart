import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';

class HomeHeader extends StatefulWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      toolbarHeight: 140,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/map-pin-house.svg',
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "San Francisco, CA",
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          side: BorderSide(color: AppColors.greyLight),
                        ),
                        icon: Lottie.asset(
                          'assets/icons/system-solid-46-notification-bell-hover-bell.json',
                          controller: _lottieController,
                          fit: BoxFit.contain,
                          width: 24,
                          height: 24,
                          onLoaded: (composition) {
                            _lottieController.duration = composition.duration;
                          },
                        ),
                        onPressed: () {
                          // _lottieController.reset();
                          // _lottieController.forward();
                        }
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          side: BorderSide(color: AppColors.greyLight),
                        ),
                        icon: const Icon(Icons.person),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                "Discover your perfect place to stay today.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
