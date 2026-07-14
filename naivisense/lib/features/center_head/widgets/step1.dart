import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/center_head/widgets/chip_group.dart';
import 'package:naivisense/features/center_head/widgets/section_label.dart';
import 'package:naivisense/features/center_head/widgets/section_title.dart';

class TherapistStep1 extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final VoidCallback onPasswordToggle;

  final DateTime? dob;
  final ValueChanged<DateTime> onDobChanged;

  final String gender;
  final List<String> genderOptions;
  final ValueChanged<String> onGenderChanged;

  final int Function(DateTime) ageYears;

  const TherapistStep1({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onPasswordToggle,
    required this.dob,
    required this.onDobChanged,
    required this.gender,
    required this.genderOptions,
    required this.onGenderChanged,
    required this.ageYears,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    Widget form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(text: 'Basic Identity', icon: Icons.person_outline),

        SizedBox(height: r.h(20)),

        TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),

        SizedBox(height: r.h(18)),

        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+919876543210',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 10) return 'Enter valid phone';
            return null;
          },
        ),

        SizedBox(height: r.h(18)),

        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email (optional)',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        SizedBox(height: r.h(18)),

        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onPasswordToggle,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),

        SizedBox(height: r.h(22)),

        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1960),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );

            if (picked != null) {
              onDobChanged(picked);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                hintText: dob == null
                    ? 'Tap to select'
                    : '${dob!.day}/${dob!.month}/${dob!.year}',
              ),
            ),
          ),
        ),

        if (dob != null) ...[
          SizedBox(height: r.h(8)),
          Text(
            'Age: ${ageYears(dob!)} years',
            style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(13)),
          ),
        ],

        SizedBox(height: r.h(22)),

        SectionLabel(label: 'Gender'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: genderOptions,
          selected: {gender},
          single: true,
          onTap: onGenderChanged,
          display: (v) => v[0].toUpperCase() + v.substring(1),
        ),
      ],
    );

    if (r.isDesktop) {
      return Center(child: SizedBox(width: 720, child: form));
    }

    if (r.isTablet) {
      return Center(child: SizedBox(width: 600, child: form));
    }

    return form;
  }
}
