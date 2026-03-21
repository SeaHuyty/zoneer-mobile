import 'package:flutter/material.dart';

class Responsive {
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTabletOrWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static int cardCrossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return 2;
    if (w < 900) return 3;
    return 4;
  }
}
