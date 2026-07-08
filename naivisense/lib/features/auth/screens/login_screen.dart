import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = '+91${_phoneCtr.text.trim()}';

    await ref.read(authProvider.notifier).login(phone, _passCtr.text.trim());
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
                            _buildHeader(context),

                            r.gapH(32, tablet: 36, desktop: 40),

                            if (error != null) _buildError(context, error),

                            TextFormField(
                              controller: _phoneCtr,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                labelText: "Mobile Number",
                                prefixText: "+91 ",
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  size: r.icon(20, tablet: 22, desktop: 24),
                                ),
                              ),
                              validator: Validators.phone,
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

  Widget _buildHeader(BuildContext context) {
    final r = Responsive(context);

    return Column(
      children: [
        Container(
          width: r.w(82, tablet: 90, desktop: 100),
          height: r.w(82, tablet: 90, desktop: 100),
          decoration: BoxDecoration(
            gradient: AppColors.therapistGradient,
            borderRadius: r.borderRadius(22, tablet: 24, desktop: 26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.psychology,
            color: Colors.white,
            size: r.icon(42, tablet: 46, desktop: 52),
          ),
        ),

        r.gapH(22, tablet: 26, desktop: 30),

        Text(
          "NaiviSense",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: r.sp(28, tablet: 32, desktop: 36),
          ),
        ),

        r.gapH(8),

        Text(
          "Therapy Coordination Platform",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: r.sp(14, tablet: 15, desktop: 16),
          ),
        ),

        r.gapH(6),

        Text(
          "Welcome back! Please sign in to your account.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: r.sp(13, tablet: 14, desktop: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final r = Responsive(context);

    return Container(
      margin: EdgeInsets.only(bottom: r.h(18)),
      padding: EdgeInsets.all(r.w(14, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: AppColors.softCoral.withValues(alpha: .10),
        borderRadius: r.borderRadius(14),
        border: Border.all(color: AppColors.softCoral.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.softCoral,
            size: r.icon(20),
          ),

          r.gapW(12),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.softCoral,
                fontSize: r.sp(13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
