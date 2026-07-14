import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: ui.ssp(13),
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }
}