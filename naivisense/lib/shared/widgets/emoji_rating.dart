import 'package:flutter/material.dart';

class EmojiRating extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  static const _emojis = ['😢', '😟', '😐', '🙂', '😄'];
  static const _labels = ['Very Bad', 'Bad', 'Okay', 'Good', 'Great'];

  const EmojiRating({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final tilePadding = (screenWidth * 0.02).clamp(6.0, 8.0);
    final tileRadius = (screenWidth * 0.03).clamp(10.0, 12.0);
    final emojiSizeSelected = (screenWidth * 0.08 * textScale).clamp(
      26.0,
      32.0,
    );
    final emojiSizeNormal = (screenWidth * 0.06 * textScale).clamp(20.0, 24.0);
    final itemSpacing = (screenWidth * 0.02).clamp(6.0, 10.0);
    final labelSpacing = (screenWidth * 0.01).clamp(2.0, 4.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth;
        final isCompact = availableWidth < 360;
        final rowItemWidth = availableWidth / 5;
        final compactItemWidth = (availableWidth - itemSpacing) / 2;

        final items = List.generate(5, (i) {
          final score = i + 1;
          final selected = value == score;
          final item = GestureDetector(
            onTap: () => onChanged(score),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.all(tilePadding),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(tileRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _emojis[i],
                    style: TextStyle(
                      fontSize: selected ? emojiSizeSelected : emojiSizeNormal,
                    ),
                  ),
                  SizedBox(height: labelSpacing),
                  Text(
                    _labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );

          if (isCompact) {
            return SizedBox(width: compactItemWidth, child: item);
          }
          return SizedBox(
            width: rowItemWidth,
            child: Center(child: item),
          );
        });

        if (isCompact) {
          return Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: itemSpacing,
            runSpacing: itemSpacing,
            children: items,
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items,
        );
      },
    );
  }
}
