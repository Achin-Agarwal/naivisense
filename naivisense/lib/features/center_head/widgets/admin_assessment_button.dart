import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class AdminAssessmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AdminAssessmentButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: r.h(14, tablet: 16, desktop: 18),
          horizontal: r.w(12, tablet: 14, desktop: 16),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(
            r.radius(14, tablet: 16, desktop: 18),
          ),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: r.icon(18, tablet: 20, desktop: 22), color: color),

            r.gapW(8, tablet: 10, desktop: 12),

            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: r.sp(13, tablet: 14, desktop: 15),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
