import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';

class ChildDropdown extends StatelessWidget {
  final AsyncValue<List<ChildModel>> children;
  final String? selectedChildId;
  final ValueChanged<String?> onChanged;

  const ChildDropdown({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return children.when(
      loading: () => const LinearProgressIndicator(),

      error: (e, _) => Text(
        'Failed to load: $e',
        style: TextStyle(
          color: AppColors.softCoral,
          fontSize: responsive.sp(13, tablet: 14, desktop: 15),
        ),
      ),

      data: (list) {
        return DropdownButtonFormField<String>(
          initialValue: selectedChildId,

          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline,
              size: responsive.icon(20, tablet: 22, desktop: 24),
            ),
            hintText: 'Select child',
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.w(14, tablet: 16, desktop: 18),
              vertical: responsive.h(14, tablet: 16, desktop: 18),
            ),
          ),

          items: list.map((child) {
            return DropdownMenuItem<String>(
              value: child.id,
              child: Text(
                '${toTitleCase(child.name)} (${child.ageYears} yrs)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                ),
              ),
            );
          }).toList(),

          onChanged: onChanged,

          validator: (value) => value == null ? 'Select a child' : null,
        );
      },
    );
  }
}
