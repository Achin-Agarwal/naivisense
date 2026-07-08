import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class MoodBadge extends StatelessWidget {
  final String mood;
  final Responsive responsive;

  const MoodBadge({
    super.key,
    required this.mood,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    final (emoji, color) = switch (mood) {
      'sad' => ('😢', const Color(0xFF5B8DEF)),
      'calm' => ('😐', AppColors.mintGreen),
      'happy' => ('🙂', AppColors.warmYellow),
      'excited' => ('😄', const Color(0xFFFF9F43)),
      _ => ('😐', AppColors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(10),
        vertical: r.h(5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: r.borderRadius(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: r.sp(
                15,
                tablet: 16,
                desktop: 17,
              ),
            ),
          ),

          r.gapW(4),

          Text(
            mood[0].toUpperCase() + mood.substring(1),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: r.sp(
                12,
                tablet: 13,
                desktop: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Note Row
/// ─────────────────────────────────────────────────────────

class NoteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String text;
  final Responsive responsive;

  const NoteRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: r.icon(
            20,
            tablet: 22,
            desktop: 24,
          ),
        ),

        r.gapW(8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: r.sp(
                    12,
                    tablet: 13,
                    desktop: 14,
                  ),
                ),
              ),

              r.gapH(2),

              Text(
                text,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: r.sp(
                    14,
                    tablet: 15,
                    desktop: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}