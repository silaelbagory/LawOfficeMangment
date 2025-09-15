import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double desktopBreakpoint = 1440;

  // Screen size detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Responsive values
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isLargeDesktop(context)) return 4;
    return 3;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // Grid delegates
  static SliverGridDelegate getResponsiveGridDelegate(BuildContext context) {
    final columns = getResponsiveColumns(context);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: getResponsivePadding(context) / 2,
      mainAxisSpacing: getResponsivePadding(context) / 2,
      childAspectRatio: isMobile(context) ? 1.2 : 1.0,
    );
  }

  // Layout builders
  static Widget responsiveBuilder({
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile(context)) return mobile;
        if (isTablet(context)) return tablet;
        return desktop;
      },
    );
  }

  // Container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    if (isMobile(context)) {
      return const BoxConstraints(maxWidth: 600);
    } else if (isTablet(context)) {
      return const BoxConstraints(maxWidth: 1000);
    } else {
      return const BoxConstraints(maxWidth: 1200);
    }
  }

  // Form field width
  static double getFormFieldWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 400;
    return 500;
  }

  // Card width
  static double getCardWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 300;
    return 350;
  }

  // Dialog width
  static double getDialogWidth(BuildContext context) {
    if (isMobile(context)) return MediaQuery.of(context).size.width * 0.9;
    if (isTablet(context)) return 500;
    return 600;
  }

  // App bar height
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 56.0,
      tablet: 64.0,
      desktop: 72.0,
    );
  }

  // Icon size
  static double getIconSize(BuildContext context, {double? size}) {
    if (size != null) return size;
    return getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
  }

  // Button height
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
  }

  // Text field height
  static double getTextFieldHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 56.0,
      tablet: 60.0,
      desktop: 64.0,
    );
  }
}

// Responsive widget wrapper
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.responsiveBuilder(
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }
}

// Responsive container
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: maxWidth != null 
          ? BoxConstraints(maxWidth: maxWidth!)
          : ResponsiveUtils.getResponsiveConstraints(context),
      padding: padding ?? EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      margin: margin,
      child: child,
    );
  }
}

// Responsive grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.getResponsiveColumns(context),
      crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtils.getResponsivePadding(context) / 2,
      mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtils.getResponsivePadding(context) / 2,
      childAspectRatio: childAspectRatio ?? (ResponsiveUtils.isMobile(context) ? 1.2 : 1.0),
      children: children,
    );
  }
}

// Responsive text
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
