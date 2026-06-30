import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool get isMobile => screenWidth < mobileBreakpoint;

  bool get isTablet =>
      screenWidth >= mobileBreakpoint &&
      screenWidth < tabletBreakpoint;

  bool get isDesktop => screenWidth >= tabletBreakpoint;

  // Width values
  double w(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Height values
  double h(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Font sizes
  double sp(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Icon sizes
  double icon(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Border radius
  double radius(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Avatar radius
  double avatar(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Horizontal padding
  double get horizontalPadding {
    if (isDesktop) return 40;
    if (isTablet) return 28;
    return 16;
  }

  // Vertical padding
  double get verticalPadding {
    if (isDesktop) return 28;
    if (isTablet) return 22;
    return 16;
  }

  // Max content width
  double get maxWidth {
    if (isDesktop) return 900;
    if (isTablet) return 700;
    return double.infinity;
  }

  EdgeInsets allPadding(
    double mobile, {
    double? tablet,
    double? desktop,
  }) {
    return EdgeInsets.all(
      w(
        mobile,
        tablet: tablet,
        desktop: desktop,
      ),
    );
  }

  EdgeInsets symmetricPadding({
    required double horizontal,
    required double vertical,
    double? horizontalTablet,
    double? horizontalDesktop,
    double? verticalTablet,
    double? verticalDesktop,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(
        horizontal,
        tablet: horizontalTablet,
        desktop: horizontalDesktop,
      ),
      vertical: h(
        vertical,
        tablet: verticalTablet,
        desktop: verticalDesktop,
      ),
    );
  }
}