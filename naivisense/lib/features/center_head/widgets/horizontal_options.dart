import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class HorizontalOptions extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final double? spacing;

  const HorizontalOptions({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return Padding(
      padding: EdgeInsets.only(bottom: ui.sh(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: ui.sIcon(ui.isMobile ? 18 : 10),
              ),

              SizedBox(width: ui.sw(2)),

              Text(
                title,
                style: TextStyle(
                  fontSize: ui.ssp(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: ui.sh(10)),

          Wrap(
            spacing: spacing ?? ui.sw(8),
            runSpacing: ui.sh(8),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }
}
