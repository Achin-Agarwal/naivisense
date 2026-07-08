import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Base design size
  static const double designWidth = 390;
  static const double designHeight = 844;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool get isMobile => screenWidth < mobileBreakpoint;

  bool get isTablet =>
      screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;

  bool get isDesktop => screenWidth >= tabletBreakpoint;

  //--------------------------------------------------------------------------
  // Existing breakpoint-based methods (UNCHANGED)
  //--------------------------------------------------------------------------

  double w(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  double h(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  double sp(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  double icon(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  double radius(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  double avatar(double mobile, {double? tablet, double? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  //--------------------------------------------------------------------------
  // NEW Scaling Helpers
  //--------------------------------------------------------------------------

  double get scaleWidth => screenWidth / designWidth;

  double get scaleHeight => screenHeight / designHeight;

  double get scaleText => scaleWidth.clamp(0.90, 1.25);

  /// Responsive width
  double sw(double value) => value * scaleWidth;

  /// Responsive height
  double sh(double value) => value * scaleHeight;

  /// Responsive font
  double ssp(double value) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return value * scaleText * textScale;
  }

  /// Responsive icon
  double sIcon(double value) => value * scaleWidth;

  /// Responsive radius
  double sRadius(double value) => value * scaleWidth;

  //--------------------------------------------------------------------------
  // Default paddings
  //--------------------------------------------------------------------------

  double get horizontalPadding {
    if (isDesktop) return 40;
    if (isTablet) return 28;
    return 16;
  }

  double get verticalPadding {
    if (isDesktop) return 28;
    if (isTablet) return 22;
    return 16;
  }

  //--------------------------------------------------------------------------
  // Max widths
  //--------------------------------------------------------------------------

  double get maxWidth {
    if (isDesktop) return 900;
    if (isTablet) return 700;
    return double.infinity;
  }

  double get formWidth {
    if (isDesktop) return 800;
    if (isTablet) return 650;
    return double.infinity;
  }

  double get dialogWidth {
    if (isDesktop) return 900;
    if (isTablet) return 760;
    return double.infinity;
  }

  //--------------------------------------------------------------------------
  // Common values
  //--------------------------------------------------------------------------

  double get sectionSpacing => h(24, tablet: 28, desktop: 32);

  double get tilePadding => w(14, tablet: 16, desktop: 18);

  //--------------------------------------------------------------------------
  // EdgeInsets
  //--------------------------------------------------------------------------

  EdgeInsets allPadding(double mobile, {double? tablet, double? desktop}) {
    return EdgeInsets.all(w(mobile, tablet: tablet, desktop: desktop));
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
      vertical: h(vertical, tablet: verticalTablet, desktop: verticalDesktop),
    );
  }

  BorderRadius borderRadius(double mobile, {double? tablet, double? desktop}) {
    return BorderRadius.circular(
      radius(mobile, tablet: tablet, desktop: desktop),
    );
  }

  SizedBox gapH(double mobile, {double? tablet, double? desktop}) {
    return SizedBox(
      height: h(mobile, tablet: tablet, desktop: desktop),
    );
  }

  SizedBox gapW(double mobile, {double? tablet, double? desktop}) {
    return SizedBox(
      width: w(mobile, tablet: tablet, desktop: desktop),
    );
  }

  double value({
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    if (isDesktop) return desktop.toDouble();
    if (isTablet) return tablet.toDouble();
    return mobile.toDouble();
  }

  double font(int mobile, {required int tablet, required int desktop}) {
    if (isDesktop) return desktop.toDouble();
    if (isTablet) return tablet.toDouble();
    return mobile.toDouble();
  }

  // Alias for sp()
  double text(double mobile, {double? tablet, double? desktop}) {
    return sp(mobile, tablet: tablet, desktop: desktop);
  }
}
