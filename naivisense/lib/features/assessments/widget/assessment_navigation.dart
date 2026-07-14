import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class AssessmentNavigation extends StatelessWidget {
  final bool loading;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSubmit;

  const AssessmentNavigation({
    super.key,
    required this.loading,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final isLast = currentPage == totalPages - 1;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final counterSize = (r.sp(12, tablet: 13, desktop: 14) * textScale).clamp(
      11.0,
      16.0,
    );

    final navContent = LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentPage + 1} / $totalPages',
                style: TextStyle(
                  fontSize: counterSize,
                  color: AppColors.textSecondary,
                ),
              ),

              r.gapH(8),

              Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: currentPage > 0 ? 1 : 0,
                      child: _NavButton(
                        label: 'Back',
                        icon: Icons.arrow_back,
                        outlined: true,
                        onTap: (!loading && currentPage > 0)
                            ? onPrevious
                            : null,
                      ),
                    ),
                  ),

                  r.gapW(10),

                  Expanded(
                    child: _NavButton(
                      label: isLast ? 'Submit' : 'Next',
                      icon: isLast
                          ? (loading ? Icons.hourglass_top : Icons.check)
                          : Icons.arrow_forward,
                      outlined: false,
                      onTap: loading ? null : (isLast ? onSubmit : onNext),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Opacity(
              opacity: currentPage > 0 ? 1 : 0,
              child: _NavButton(
                label: 'Back',
                icon: Icons.arrow_back,
                outlined: true,
                onTap: (!loading && currentPage > 0) ? onPrevious : null,
              ),
            ),

            const Spacer(),

            Text(
              '${currentPage + 1} / $totalPages',
              style: TextStyle(
                fontSize: counterSize,
                color: AppColors.textSecondary,
              ),
            ),

            const Spacer(),

            _NavButton(
              label: isLast ? 'Submit' : 'Next',
              icon: isLast
                  ? (loading ? Icons.hourglass_top : Icons.check)
                  : Icons.arrow_forward,
              outlined: false,
              onTap: loading ? null : (isLast ? onSubmit : onNext),
            ),
          ],
        );
      },
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.horizontalPadding,
          vertical: r.verticalPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxWidth),
            child: navContent,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final color = outlined ? AppColors.textSecondary : AppColors.primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.w(14, tablet: 16, desktop: 20),
            vertical: r.h(10, tablet: 11, desktop: 12),
          ),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(
              r.radius(10, tablet: 11, desktop: 12),
            ),
            border: outlined
                ? Border.all(color: color.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (outlined) ...[
                Icon(
                  icon,
                  size: r.icon(16, tablet: 18, desktop: 20),
                  color: color,
                ),
                r.gapW(6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: r.sp(14, tablet: 15, desktop: 16),
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : Colors.white,
                ),
              ),
              if (!outlined) ...[
                r.gapW(6),
                Icon(
                  icon,
                  size: r.icon(16, tablet: 18, desktop: 20),
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
