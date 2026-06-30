import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  const RatingSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final horizontalPadding = (screenWidth * 0.03).clamp(10.0, 12.0);
    final verticalPadding = (screenWidth * 0.01).clamp(3.0, 4.0);
    final chipRadius = (screenWidth * 0.05).clamp(16.0, 20.0);
    final sectionSpacing = (screenWidth * 0.02).clamp(6.0, 10.0);
    final compactSpacing = (screenWidth * 0.015).clamp(4.0, 8.0);
    final sliderHorizontalPadding = (screenWidth * 0.01).clamp(0.0, 4.0);

    final valueChip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(chipRadius),
      ),
      child: Text(
        '$value/10',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth;
        final isCompact = availableWidth < (320 * textScale);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: compactSpacing),
                  valueChip,
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(width: compactSpacing),
                  valueChip,
                ],
              ),
            SizedBox(height: sectionSpacing),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sliderHorizontalPadding,
              ),
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.primaryBlue,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ],
        );
      },
    );
  }
}
