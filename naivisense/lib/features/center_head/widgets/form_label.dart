import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';


class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: r.sp(
          13,
          tablet: 14,
          desktop: 15,
        ),
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}