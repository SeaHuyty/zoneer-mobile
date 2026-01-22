import 'package:flutter/material.dart';

class AppDecoration {
  static BoxDecoration card({double radius = 15, Color colors = Colors.white}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: colors,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}