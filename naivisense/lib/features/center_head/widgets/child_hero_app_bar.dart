import 'package:flutter/material.dart';
import 'package:naivisense/data/models/child.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'severity_badge.dart';

class ChildHeroAppBar extends StatelessWidget {
  final ChildModel child;

  const ChildHeroAppBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return SliverAppBar(
      expandedHeight: r.h(200, tablet: 220, desktop: 240),
      pinned: true,
      backgroundColor: AppColors.centerHeadGradient.colors.last,
      leading: const BackButton(color: Colors.white),
      actions: [
        Container(
          margin: EdgeInsets.only(
            right: r.w(16, tablet: 20, desktop: 24),
            top: r.h(10, tablet: 12, desktop: 14),
            bottom: r.h(10, tablet: 12, desktop: 14),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: r.w(12, tablet: 14, desktop: 16),
            vertical: r.h(6, tablet: 8, desktop: 10),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: r.borderRadius(20, tablet: 22, desktop: 24),
          ),
          child: Text(
            'Admin View',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.sp(12, tablet: 13, desktop: 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.centerHeadGradient,
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: r.isDesktop ? 900 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    r.horizontalPadding,
                    r.h(56, tablet: 60, desktop: 64),
                    r.horizontalPadding,
                    r.h(20, tablet: 24, desktop: 28),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: r.avatar(32, tablet: 36, desktop: 40),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          child.name.isNotEmpty
                              ? child.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: r.sp(26, tablet: 28, desktop: 32),
                          ),
                        ),
                      ),

                      r.gapW(16, tablet: 20, desktop: 24),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              child.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: r.sp(22, tablet: 26, desktop: 30),
                              ),
                            ),

                            r.gapH(4, tablet: 6, desktop: 8),

                            Text(
                              '${child.ageYears} years old',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: r.sp(14, tablet: 15, desktop: 16),
                              ),
                            ),

                            r.gapH(8, tablet: 10, desktop: 12),

                            SeverityBadge(severity: child.severity),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
