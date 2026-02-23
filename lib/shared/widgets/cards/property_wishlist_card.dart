import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';

/// Reusable horizontal property card.
///
/// Matches the wishlist card style from the design reference:
/// image on the left, name + strikethrough price on the right,
/// a full-width CTA button at the bottom, and an optional delete icon.
///
/// Parameters:
/// - [onRemove]          : shows a trash icon; triggers removal confirmation.
/// - [onTap]             : navigates to property detail.
/// - [actionButtonLabel] : label for the CTA button (default "View Details").
class WishlistPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final String actionButtonLabel;

  const WishlistPropertyCard({
    super.key,
    required this.property,
    this.onRemove,
    this.onTap,
    this.actionButtonLabel = 'View Details',
  });

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Remove from Wishlist'),
        content: const Text(
          'Are you sure you want to remove this property from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRemove?.call();
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Left: thumbnail ────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  property.thumbnail,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 95,
                    height: 95,
                    color: AppColors.greyLight,
                    child: Icon(
                      Icons.home_outlined,
                      color: AppColors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ── Right: details ──────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // Name row + delete icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${property.price.toStringAsFixed(0)}/month',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (onRemove != null) ...[  
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _confirmRemove(context),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: AppColors.primaryLight,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Address row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.address,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        // CTA button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onTap,
                            label: Text(
                              actionButtonLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: Icon(Icons.remove_red_eye, color: Colors.white,),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
