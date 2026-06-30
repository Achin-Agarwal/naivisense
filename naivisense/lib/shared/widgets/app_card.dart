import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Card(
      color: color,
      child: GestureDetector(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : screenWidth;
            final defaultPadding = (availableWidth * 0.04).clamp(12.0, 16.0);

            return Padding(
              padding: padding ?? EdgeInsets.all(defaultPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: availableWidth),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
