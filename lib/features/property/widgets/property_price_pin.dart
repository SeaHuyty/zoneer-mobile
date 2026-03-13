import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';

/// Price-pill marker shown on the map when zoomed out (zoom < 12).
/// Displays a compact pill with the formatted price and a small downward tail.
class PropertyPricePin extends StatelessWidget {
  final PropertyModel property;
  final bool isSelected;
  final VoidCallback onTap;

  const PropertyPricePin({
    super.key,
    required this.property,
    this.isSelected = false,
    required this.onTap,
  });

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(1)}k';
    }
    return '\$${price.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primary : Colors.white;
    final textColor = isSelected ? Colors.white : Colors.black87;
    final borderColor = isSelected ? AppColors.primary : Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pill body ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: isSelected ? 0.25 : 0.15),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _formatPrice(property.price),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          // ── Downward triangle tail ────────────────────────────
          CustomPaint(
            size: const Size(10, 5),
            painter: _TrianglePainter(color: bgColor),
          ),
        ],
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
