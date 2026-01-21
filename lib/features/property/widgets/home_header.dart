import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/providers/service_provider.dart';

class HomeHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader>
    with TickerProviderStateMixin {
  late AnimationController _notificationController;
  late AnimationController _accountController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _accountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _handleLocationRequest() async {
    setState(() => _isLoadingLocation = true);

    try {
      await ref.read(currentCityProvider.notifier).fetchCurrentCity();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCity = ref.watch(currentCityProvider);

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
                        onPressed: _isLoadingLocation
                            ? null
                            : _handleLocationRequest,
                      ),
                      GestureDetector(
                        onTap: _isLoadingLocation
                            ? null
                            : _handleLocationRequest,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  currentCity,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: AppColors.greyLight),
                          padding: EdgeInsets.zero,
                        ),
                        icon: Lottie.asset(
                          'assets/icons/system-solid-46-notification-bell-hover-bell.json',
                          controller: _notificationController,
                          width: 28,
                          height: 28,
                          onLoaded: (composition) {
                            _notificationController.duration =
                                composition.duration;
                          },
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: Lottie.asset(
                          'assets/icons/system-solid-8-account-hover-pinch.json',
                          controller: _accountController,
                          width: 28,
                          height: 28,
                          onLoaded: (composition) {
                            _accountController.duration = composition.duration;
                          },
                        ),
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
