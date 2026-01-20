import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/core/providers/navigation_provider.dart';
import 'package:zoneer_mobile/features/property/views/home_view.dart';
import 'package:zoneer_mobile/features/wishlist/views/wishlist_view.dart';
import 'package:zoneer_mobile/features/property/views/map_view.dart';
import 'package:zoneer_mobile/features/user/views/profile_view.dart';

class GoogleNavBar extends ConsumerStatefulWidget {
  const GoogleNavBar({super.key});

  @override
  ConsumerState<GoogleNavBar> createState() => _GoogleNavBarState();
}

class _GoogleNavBarState extends ConsumerState<GoogleNavBar>
    with TickerProviderStateMixin {
  late AnimationController _homeController;
  late AnimationController _wishlistController;
  late AnimationController _mapController;
  late AnimationController _profileController;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    WishlistView(),
    MapView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _homeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _wishlistController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _profileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _homeController.dispose();
    _wishlistController.dispose();
    _mapController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: AppColors.primaryLight.withOpacity(0.2),
              hoverColor: AppColors.greyLight,
              gap: 8,
              activeColor: AppColors.primary,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primary.withOpacity(0.1),
              color: AppColors.secondary,
              tabs: [
                GButton(
                  icon: Icons.home,
                  leading: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 0
                          ? AppColors.primary
                          : AppColors.secondary,
                      BlendMode.srcIn,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Lottie.asset(
                        'lib/assets/icons/system-solid-41-home-hover-pinch.json',
                        controller: _homeController,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _homeController.duration = composition.duration;
                        },
                      ),
                    ),
                  ),
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.bookmark,
                  leading: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 1
                          ? AppColors.primary
                          : AppColors.secondary,
                      BlendMode.srcIn,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Lottie.asset(
                        'lib/assets/icons/system-solid-20-bookmark-hover-bookmark-1.json',
                        controller: _wishlistController,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _wishlistController.duration = composition.duration;
                        },
                      ),
                    ),
                  ),
                  text: 'Wishlist',
                ),
                GButton(
                  icon: Icons.map,
                  leading: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 2
                          ? AppColors.primary
                          : AppColors.secondary,
                      BlendMode.srcIn,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Lottie.asset(
                        'lib/assets/icons/droppin.json',
                        controller: _mapController,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _mapController.duration = composition.duration;
                        },
                      ),
                    ),
                  ),
                  text: 'Map',
                ),
                GButton(
                  icon: Icons.person,
                  leading: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      selectedIndex == 3
                          ? AppColors.primary
                          : AppColors.secondary,
                      BlendMode.srcIn,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Lottie.asset(
                        'lib/assets/icons/system-solid-8-account-hover-pinch.json',
                        controller: _profileController,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _profileController.duration = composition.duration;
                        },
                      ),
                    ),
                  ),
                  text: 'Profile',
                ),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                ref.read(navigationProvider.notifier).changeTab(index);
                // Play animation for selected tab
                switch (index) {
                  case 0:
                    _homeController.forward(from: 0);
                    break;
                  case 1:
                    _wishlistController.forward(from: 0);
                    break;
                  case 2:
                    _mapController.forward(from: 0);
                    break;
                  case 3:
                    _profileController.forward(from: 0);
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
