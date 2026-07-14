import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';


class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: r.sp(
          14,
          tablet: 15,
          desktop: 16,
        ),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: r.sp(
            14,
            tablet: 15,
            desktop: 16,
          ),
          color: AppColors.textSecondary,
        ),

        prefixIcon: Icon(
          icon,
          color: AppColors.textSecondary,
          size: r.icon(
            20,
            tablet: 22,
            desktop: 24,
          ),
        ),

        filled: true,
        fillColor: AppColors.surface,

        contentPadding: EdgeInsets.symmetric(
          horizontal: r.w(
            16,
            tablet: 18,
            desktop: 20,
          ),
          vertical: r.h(
            16,
            tablet: 17,
            desktop: 18,
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: r.borderRadius(
            12,
            tablet: 14,
            desktop: 16,
          ),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: r.borderRadius(
            12,
            tablet: 14,
            desktop: 16,
          ),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: r.borderRadius(
            12,
            tablet: 14,
            desktop: 16,
          ),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: r.borderRadius(
            12,
            tablet: 14,
            desktop: 16,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: r.borderRadius(
            12,
            tablet: 14,
            desktop: 16,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}