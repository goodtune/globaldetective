import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart' as rf;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (rf.ResponsiveBreakpoints.of(context).isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (rf.ResponsiveBreakpoints.of(context).isTablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoints = rf.ResponsiveBreakpoints.of(context);
    final isMobile = breakpoints.isMobile;
    final isTablet = breakpoints.isTablet;
    final isDesktop = breakpoints.isDesktop;

    return builder(context, isMobile, isTablet, isDesktop);
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        EdgeInsetsGeometry padding;
        
        if (isDesktop) {
          padding = desktopPadding ?? const EdgeInsets.all(32);
        } else if (isTablet) {
          padding = tabletPadding ?? const EdgeInsets.all(24);
        } else {
          padding = mobilePadding ?? const EdgeInsets.all(16);
        }

        return Container(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        int columns;
        
        if (isDesktop) {
          columns = desktopColumns;
        } else if (isTablet) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}