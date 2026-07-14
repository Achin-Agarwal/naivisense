import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class InfoBanner extends StatelessWidget {
  final String childName;

  const InfoBanner({super.key, required this.childName});

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Responsive.mobileBreakpoint;

        return Container(
          padding: EdgeInsets.all(isMobile ? ui.sw(6) : ui.sw(8)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(ui.sRadius(8)),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: isMobile ? ui.sIcon(6) : ui.sIcon(10),
              ),

              SizedBox(width: isMobile ? ui.sw(4) : ui.sw(8)),

              Expanded(
                child: Text(
                  "Alerts are sent directly to $childName's therapy team. "
                  "For medical emergencies, please call emergency services immediately.",
                  style: TextStyle(
                    fontSize: isMobile ? ui.ssp(12) : ui.ssp(13),
                    color: AppColors.primaryBlue,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
