import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1200 && width < 1920;
  }

  static bool isTV(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1920;
  }

  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 42;
    if (isTablet(context)) return 55;
    if (isDesktop(context)) return 65;
    return 80;
  }

  static double getFontSize(
    BuildContext context, {
    double mobile = 14,
    double tablet = 18,
    double desktop = 22,
    double tv = 26,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    if (isDesktop(context)) return desktop;
    return tv;
  }

  static double getKeypadButtonHeight(BuildContext context) {
    if (isMobile(context)) return 70;
    if (isTablet(context)) return 90;
    if (isDesktop(context)) return 110;
    return 140;
  }

  static EdgeInsets getDialogPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(20);
    if (isDesktop(context)) return const EdgeInsets.all(28);
    return const EdgeInsets.all(36);
  }

  static double scaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 0.9;
    if (width < 1200) return 1.0;
    if (width < 1920) return 1.1;
    return 1.2;
  }
}
