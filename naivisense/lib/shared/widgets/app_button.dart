import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final loaderSize = (screenWidth * 0.05).clamp(18.0, 20.0).toDouble();
    final iconSize = (screenWidth * 0.045 * textScale)
        .clamp(16.0, 18.0)
        .toDouble();
    final iconSpacing = (screenWidth * 0.02).clamp(6.0, 8.0).toDouble();

    final child = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth * 0.9;
        final maxLabelWidth = icon != null
            ? (availableWidth - iconSize - iconSpacing)
                  .clamp(0.0, screenWidth)
                  .toDouble()
            : availableWidth.clamp(0.0, screenWidth).toDouble();

        if (loading) {
          return SizedBox.square(
            dimension: loaderSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize),
              SizedBox(width: iconSpacing),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxLabelWidth),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        );
      },
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: child,
      );
    }
    return ElevatedButton(onPressed: loading ? null : onPressed, child: child);
  }
}
