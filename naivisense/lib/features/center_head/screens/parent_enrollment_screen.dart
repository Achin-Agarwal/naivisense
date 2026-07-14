import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/center_head/widgets/app_text_field.dart';
import 'package:naivisense/features/center_head/widgets/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/parent_enrollment_provider.dart';

class ParentEnrollmentScreen extends ConsumerStatefulWidget {
  const ParentEnrollmentScreen({super.key});

  @override
  ConsumerState<ParentEnrollmentScreen> createState() =>
      _ParentEnrollmentScreenState();
}

class _ParentEnrollmentScreenState
    extends ConsumerState<ParentEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'password': _passwordCtrl.text,
    };
    if (_emailCtrl.text.trim().isNotEmpty) {
      data['email'] = _emailCtrl.text.trim();
    }

    final ok = await ref.read(parentEnrollmentProvider.notifier).submit(data);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent registered successfully'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentEnrollmentProvider);
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Register New Parent',
          style: TextStyle(fontSize: r.sp(18, tablet: 20, desktop: 22)),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.formWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(r.horizontalPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Container(
                    padding: r.allPadding(20, tablet: 24, desktop: 28),
                    decoration: BoxDecoration(
                      gradient: AppColors.parentGradient,
                      borderRadius: r.borderRadius(16, tablet: 18, desktop: 20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: r.allPadding(10, tablet: 12, desktop: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: r.borderRadius(
                              12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                          child: Icon(
                            Icons.family_restroom,
                            color: Colors.white,
                            size: r.icon(28, tablet: 30, desktop: 32),
                          ),
                        ),

                        r.gapW(14, tablet: 16, desktop: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parent Account',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: r.sp(
                                        16,
                                        tablet: 20,
                                        desktop: 22,
                                      ),
                                    ),
                              ),

                              r.gapH(4),

                              Text(
                                'Create login credentials for the parent',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: r.sp(
                                        12,
                                        tablet: 13,
                                        desktop: 14,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  r.gapH(28, tablet: 32, desktop: 36),

                  const SectionLabel(label: 'Full Name'),

                  r.gapH(8),

                  AppTextField(
                    controller: _nameCtrl,
                    hint: "Parent's full name",
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Name must be at least 2 characters'
                        : null,
                  ),

                  r.gapH(16),

                  const SectionLabel(label: 'Phone Number'),

                  r.gapH(8),

                  AppTextField(
                    controller: _phoneCtrl,
                    hint: 'e.g. 9876543210',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Enter a valid phone number'
                        : null,
                  ),

                  r.gapH(16),

                  const SectionLabel(label: 'Email Address (optional)'),

                  r.gapH(8),

                  AppTextField(
                    controller: _emailCtrl,
                    hint: 'parent@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return null;
                      }

                      final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+');

                      return emailReg.hasMatch(v.trim())
                          ? null
                          : 'Enter a valid email';
                    },
                  ),

                  r.gapH(16),

                  // Continue with Password field...
                  // Password
                  const SectionLabel(label: 'Password'),

                  r.gapH(8, tablet: 9, desktop: 10),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_showPassword,
                    style: TextStyle(
                      fontSize: r.sp(14, tablet: 15, desktop: 16),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Minimum 6 characters',
                      hintStyle: TextStyle(
                        fontSize: r.sp(14, tablet: 15, desktop: 16),
                        color: AppColors.textSecondary,
                      ),

                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                        size: r.icon(20, tablet: 22, desktop: 24),
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: r.icon(20, tablet: 22, desktop: 24),
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),

                      filled: true,
                      fillColor: AppColors.surface,

                      contentPadding: EdgeInsets.symmetric(
                        horizontal: r.w(16, tablet: 18, desktop: 20),
                        vertical: r.h(16, tablet: 17, desktop: 18),
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
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),

                  r.gapH(12, tablet: 14, desktop: 16),

                  // Info Card
                  Container(
                    padding: r.allPadding(12, tablet: 14, desktop: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.06),
                      borderRadius: r.borderRadius(10, tablet: 12, desktop: 14),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryBlue,
                          size: r.icon(16, tablet: 17, desktop: 18),
                        ),

                        r.gapW(8, tablet: 9, desktop: 10),

                        Expanded(
                          child: Text(
                            "The parent will use these credentials to log in and track their child's progress.",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primaryBlue,
                                  height: 1.4,
                                  fontSize: r.sp(12, tablet: 13, desktop: 14),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (state.error != null) ...[
                    r.gapH(16, tablet: 18, desktop: 20),

                    Container(
                      width: double.infinity,
                      padding: r.allPadding(12, tablet: 14, desktop: 16),
                      decoration: BoxDecoration(
                        color: AppColors.softCoral.withValues(alpha: 0.1),
                        borderRadius: r.borderRadius(
                          10,
                          tablet: 12,
                          desktop: 14,
                        ),
                        border: Border.all(
                          color: AppColors.softCoral.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: AppColors.softCoral,
                          fontSize: r.sp(13, tablet: 14, desktop: 15),
                        ),
                      ),
                    ),
                  ],

                  r.gapH(28, tablet: 32, desktop: 36),

                  SizedBox(
                    width: double.infinity,
                    height: r.h(52, tablet: 54, desktop: 56),
                    child: ElevatedButton(
                      onPressed: state.loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mintGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: r.borderRadius(
                            14,
                            tablet: 15,
                            desktop: 16,
                          ),
                        ),
                      ),
                      child: state.loading
                          ? SizedBox(
                              width: r.icon(22),
                              height: r.icon(22),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Register Parent',
                              style: TextStyle(
                                fontSize: r.sp(16, tablet: 16, desktop: 17),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
