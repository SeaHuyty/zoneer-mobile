import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';

/// Empty state widget shown when user has no wishlist items.
/// Supports two states: not logged in (with Register/Login buttons) and logged in (empty).
class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({super.key});

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
              'Start adding your favorite properties!',

              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
