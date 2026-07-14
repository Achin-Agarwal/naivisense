import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class CustomSwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return SwitchListTile(
      value: value,
      title: Text(label, style: TextStyle(fontSize: ui.ssp(14))),
      activeThumbColor: AppColors.primaryBlue,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}
