import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class TherapistDropdown extends StatelessWidget {
  final List therapists;
  final String? value;
  final ValueChanged<String?> onChanged;

  const TherapistDropdown({
    super.key,
    required this.therapists,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: r.w(12),
          vertical: r.h(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius(10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius(10)),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.radius(10)),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
      ),
      hint: Text(
        'Unassigned',
        style: TextStyle(fontSize: r.font(13, tablet: 14, desktop: 15)),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            '— Unassigned —',
            style: TextStyle(fontSize: r.font(13, tablet: 14, desktop: 15)),
          ),
        ),
        ...therapists.map(
          (u) => DropdownMenuItem<String>(
            value: u.id,
            child: Text(
              u.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: r.font(13, tablet: 14, desktop: 15)),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
