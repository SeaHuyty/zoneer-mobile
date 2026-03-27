import 'package:flutter/material.dart';

class AppDecoration {
  static BoxDecoration card({double radius = 15, Color colors = Colors.white}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: colors,
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(22, 0, 0, 0),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
