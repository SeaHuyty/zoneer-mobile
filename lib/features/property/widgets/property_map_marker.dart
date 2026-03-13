import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/enums/property_status.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';

/// Thumbnail card marker shown on the map.
/// Anchor is at bottom-center of the triangle tail.
class PropertyMapMarker extends StatelessWidget {
  final PropertyModel property;
  final bool isSelected;
  final VoidCallback onTap;

  const PropertyMapMarker({
    super.key,
    required this.property,
    this.isSelected = false,
    required this.onTap,
  });

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(1)}k/mo';
    }
    return '\$${price.toInt()}/mo';
  }

  @override
  Widget build(BuildContext context) {
    final isRented = property.propertyStatus == PropertyStatus.rented;
    final cardWidth = isSelected ? 125.0 : 110.0;
    final cardHeight = isSelected ? 120.0 : 105.0;
    final borderColor = isSelected ? AppColors.primary : Colors.white;
    final borderWidth = isSelected ? 2.0 : 1.5;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Card body ────────────────────────────────────────
          Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: isSelected ? 0.25 : 0.15),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Thumbnail ────────────────────────────────
                Expanded(
                  flex: 7,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(9)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(isRented),
                          if (isRented) _buildRentedOverlay(),
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Price strip ──────────────────────────────
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(9)),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _formatPrice(property.price),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Downward triangle tail ───────────────────────────
          CustomPaint(
            size: const Size(16, 8),
            painter: _TrianglePainter(
              color: isSelected ? AppColors.primary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isRented) {
    if (property.thumbnail.isEmpty) {
      return Container(color: Colors.grey[300]);
    }
    final image = CachedNetworkImage(
      imageUrl: property.thumbnail,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.grey[200]),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 20),
      ),
    );
    if (isRented) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: image,
      );
    }
    return image;
  }

  Widget _buildRentedOverlay() {
    return Positioned(
      bottom: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Rented',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}
