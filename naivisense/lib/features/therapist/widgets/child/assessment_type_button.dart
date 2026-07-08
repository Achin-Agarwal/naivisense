import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/responsive.dart';

class AssessmentTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AssessmentTypeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return InkWell(
      onTap: onTap,
      borderRadius: responsive.borderRadius(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(16, tablet: 18, desktop: 20),
          vertical: responsive.h(14, tablet: 16, desktop: 18),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: responsive.borderRadius(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: responsive.icon(20, tablet: 22, desktop: 24),
            ),

            responsive.gapW(10),

            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
