import 'package:flutter/material.dart';

class PropertyMapMarker extends StatelessWidget {
  final double price;
  final bool isSelected;

  const PropertyMapMarker({
    super.key,
    required this.price,
    this.isSelected = false,
  });

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(1)}k';
    }
    return '\$${price.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2196F3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _formatPrice(price),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
