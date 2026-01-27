import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';

/// Empty state widget shown when user has no wishlist items.
/// Supports two states: not logged in (with Register/Login buttons) and logged in (empty).
class WishlistEmptyState extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback? onRegister;
  final VoidCallback? onLogin;

  const WishlistEmptyState({
    super.key,
    this.isLoggedIn = false,
    this.onRegister,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Map icon with circle background
            Image.asset('assets/images/empty_wishlist.png'),
            const SizedBox(height: 24),

            // Title
            Text(
              'Opp! your wishlist is empty.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              isLoggedIn
                  ? 'Start adding your favorite properties!'
                  : 'Please register or login to get started!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Buttons (only show if not logged in)
            if (!isLoggedIn)
              Row(
                children: [
                  // Register Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Login Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLogin,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
