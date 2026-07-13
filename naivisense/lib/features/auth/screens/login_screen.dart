import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:naivisense/features/auth/widgets/app_header.dart';
import 'package:naivisense/features/auth/widgets/responsive_error_banner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneCtr = TextEditingController();
  final _passCtr = TextEditingController();

  /// Stores the full international phone number.
  /// Example:
  /// +919876543210
  /// +15551234567
  String _completePhone = '';

  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_completePhone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number')),
      );
      return;
    }

    await ref
        .read(authProvider.notifier)
        .login(_completePhone, _passCtr.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final authState = ref.watch(authProvider);

    final loading =
        authState.isLoading || (authState.valueOrNull?.loading ?? false);

    final error = authState.valueOrNull?.error;

    ref.listen(authProvider, (_, next) {
      final state = next.valueOrNull;

      if (state == null) return;

      if (state.status == AuthStatus.authenticated) {
        switch (state.user?.role) {
          case 'therapist':
            context.go('/therapist');
            break;

          case 'parent':
            context.go('/parent');
            break;

          case 'center_head':
            context.go('/center-head');
            break;
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: r.horizontalPadding,
                  vertical: r.verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: r.formWidth),
                  child: Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: r.borderRadius(22, tablet: 24, desktop: 26),
                      side: BorderSide(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(r.w(22, tablet: 28, desktop: 34)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppHeader(
                              title: "Welcome Back",
                              subtitle: "Sign in to continue",
                              description:
                                  "Enter your mobile number and password to access your account",
                            ),

                            r.gapH(32, tablet: 36, desktop: 40),

                            if (error != null)
                              ResponsiveErrorBanner(message: error),
                            IntlPhoneField(
                              controller: _phoneCtr,
                              initialCountryCode: 'IN',
                              disableLengthCheck: false,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.background,
                                labelText: "Mobile Number",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: r.sp(15, tablet: 16, desktop: 17),
                              ),
                              dropdownIcon: const Icon(Icons.arrow_drop_down),
                              onChanged: (phone) {
                                _completePhone = phone.completeNumber;
                              },
                              validator: (phone) {
                                if (phone == null ||
                                    phone.number.trim().isEmpty) {
                                  return 'Please enter your mobile number';
                                }
                                return null;
                              },
                            ),

                            r.gapH(18),

                            TextFormField(
                              controller: _passCtr,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: r.icon(20, tablet: 22, desktop: 24),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscure = !_obscure;
                                    });
                                  },
                                ),
                              ),
                              validator: Validators.password,
                            ),

                            r.gapH(28, tablet: 32, desktop: 36),

                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                label: "Sign In",
                                loading: loading,
                                onPressed: _submit,
                              ),
                            ),

                            r.gapH(8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
