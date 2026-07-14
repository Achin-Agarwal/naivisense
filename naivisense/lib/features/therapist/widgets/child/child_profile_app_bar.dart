import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';

class ChildProfileAppBar extends StatelessWidget {
  final ChildModel child;

  const ChildProfileAppBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (severityLabel, severityColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('Unknown', Colors.grey),
    };

    return SliverAppBar(
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: AppColors.therapistGradient.colors.last,

      expandedHeight: r.isDesktop
          ? 200
          : r.isTablet
          ? 150
          : 100,

      leading: const BackButton(color: Colors.white),

      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,

        background: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Gradient background
            Container(
              decoration: BoxDecoration(gradient: AppColors.therapistGradient),
            ),

            /// Decorative circles
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            Positioned(
              left: -50,
              bottom: 40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            /// Floating profile card
            Positioned(
              left: r.horizontalPadding,
              right: r.horizontalPadding,
              bottom: 20,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(r.w(18)),
                  child: Row(
                    children: [
                      Hero(
                        tag: child.id,
                        child: CircleAvatar(
                          radius: r.avatar(34, tablet: 42, desktop: 48),
                          backgroundColor: AppColors.primaryBlue.withValues(
                            alpha: .15,
                          ),
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: r.sp(24, tablet: 28, desktop: 32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      r.gapW(18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toTitleCase(child.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.sp(20, tablet: 22, desktop: 24),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            r.gapH(8),

                            Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  size: r.icon(16),
                                  color: AppColors.textSecondary,
                                ),

                                r.gapW(6),

                                Text(
                                  "${child.ageYears} years",
                                  style: TextStyle(
                                    fontSize: r.sp(13),
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            r.gapH(10),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: r.w(12),
                                    vertical: r.h(5),
                                  ),
                                  decoration: BoxDecoration(
                                    color: severityColor.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    severityLabel,
                                    style: TextStyle(
                                      color: severityColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: r.sp(12),
                                    ),
                                  ),
                                ),

                                ...child.diagnosis.map(
                                  (diagnosis) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: r.w(12),
                                      vertical: r.h(5),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: .10,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      diagnosis,
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: r.sp(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
