import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SettingForm extends StatelessWidget {
  final TextEditingController keyController;
  final TextEditingController valueController;
  final bool saving;
  final VoidCallback onSave;

  const SettingForm({
    super.key,
    required this.keyController,
    required this.valueController,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      margin: EdgeInsets.all(r.w(16, tablet: 20, desktop: 24)),
      padding: EdgeInsets.all(r.w(16, tablet: 20, desktop: 24)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          r.radius(16, tablet: 16, desktop: 18),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add / Update Setting',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: r.sp(15, tablet: 17, desktop: 18),
            ),
          ),

          r.gapH(16, tablet: 18, desktop: 20),

          TextField(
            controller: keyController,
            decoration: const InputDecoration(
              labelText: 'Key (e.g. session_fee_default)',
              border: OutlineInputBorder(),
            ),
          ),

          r.gapH(12, tablet: 14, desktop: 16),

          TextField(
            controller: valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
          ),

          r.gapH(16, tablet: 18, desktop: 20),

          SizedBox(
            width: double.infinity,
            height: r.h(48, tablet: 50, desktop: 54),
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    r.radius(10, tablet: 10, desktop: 12),
                  ),
                ),
              ),
              child: saving
                  ? SizedBox(
                      height: r.icon(20, tablet: 20, desktop: 22),
                      width: r.icon(20, tablet: 20, desktop: 22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Setting',
                      style: TextStyle(
                        fontSize: r.sp(14, tablet: 14, desktop: 15),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
