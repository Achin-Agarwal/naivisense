import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';

class ParentHeader extends StatelessWidget {
  final String parentName;

  const ParentHeader({super.key, required this.parentName});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      width: double.infinity,
      padding: r.allPadding(20, tablet: 24, desktop: 28),
      decoration: BoxDecoration(
        gradient: AppColors.parentGradient,
        borderRadius: r.borderRadius(22, tablet: 24, desktop: 28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: .15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: r.isMobile
          ? _mobileLayout(context, r)
          : _desktopLayout(context, r),
    );
  }

  Widget _mobileLayout(BuildContext context, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_avatar(r), r.gapH(18), _texts(context, r)],
    );
  }

  Widget _desktopLayout(BuildContext context, Responsive r) {
    return Row(
      children: [
        Expanded(child: _texts(context, r)),
        _avatar(r),
      ],
    );
  }

  Widget _texts(BuildContext context, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "👋 Welcome Back",
          style: TextStyle(
            color: Colors.white70,
            fontSize: r.sp(14, tablet: 15, desktop: 16),
            fontWeight: FontWeight.w500,
          ),
        ),

        r.gapH(8),

        Text(
          parentName,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.sp(30, tablet: 34, desktop: 38),
            fontWeight: FontWeight.bold,
            letterSpacing: -.5,
          ),
        ),

        r.gapH(10),

        Text(
          AppDateUtils.formatDate(DateTime.now()),
          style: TextStyle(
            color: Colors.white70,
            fontSize: r.sp(13, tablet: 14, desktop: 15),
          ),
        ),

        r.gapH(20),

        Container(
          padding: EdgeInsets.symmetric(horizontal: r.w(14), vertical: r.h(8)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: r.icon(16, tablet: 18, desktop: 20),
              ),

              r.gapW(8),

              Text(
                "Let's track your child's progress",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: r.sp(12, tablet: 13, desktop: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar(Responsive r) {
    return Container(
      height: r.avatar(72, tablet: 82, desktop: 92),
      width: r.avatar(72, tablet: 82, desktop: 92),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .18),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.family_restroom,
        color: Colors.white,
        size: r.icon(34, tablet: 40, desktop: 46),
      ),
    );
  }
}
