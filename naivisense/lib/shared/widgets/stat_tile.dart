import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final theme = Theme.of(context);

    final paddingValue = (screenWidth * 0.04).clamp(12.0, 16.0);
    final radiusValue = (screenWidth * 0.04).clamp(12.0, 16.0);
    final iconSize = (screenWidth * 0.055 * textScale).clamp(18.0, 22.0);
    final spacingLarge = (screenWidth * 0.02).clamp(6.0, 8.0);
    final spacingSmall = (screenWidth * 0.006).clamp(1.0, 2.0);

    return Container(
      padding: EdgeInsets.all(paddingValue),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusValue),
        border: Border.all(color: AppColors.divider),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryBlue,
                  size: iconSize,
                ),
                SizedBox(height: spacingLarge),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(height: spacingSmall),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
