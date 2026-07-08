import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
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

    await ref.read(authProvider.notifier).login(phone, _passCtr.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loading =
        authState.isLoading || (authState.valueOrNull?.loading ?? false);
    final error = authState.valueOrNull?.error;

    ref.listen(authProvider, (_, next) {
      final state = next.valueOrNull;
      if (state == null) return;

      if (state.status == AuthStatus.authenticated) {
        final role = state.user?.role ?? '';

        switch (role) {
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);

            final screenWidth = media.size.width;
            final screenHeight = media.size.height;
            final textScale = media.textScaler.scale(1.0);
            final keyboardInset = media.viewInsets.bottom;

            // Responsive breakpoints for mobile/tablet/desktop layouts.
            final isMobile = constraints.maxWidth < 600;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
            final isDesktop = constraints.maxWidth >= 1024;

            final horizontalPadding = isMobile
                ? (screenWidth * 0.06).clamp(16.0, 24.0).toDouble()
                : (screenWidth * 0.04).clamp(24.0, 36.0).toDouble();

            final topSpacing = (screenHeight * 0.06)
                .clamp(28.0, 56.0)
                .toDouble();
            final betweenSpacing = (screenHeight * 0.05)
                .clamp(24.0, 48.0)
                .toDouble();
            final fieldSpacing = (screenHeight * 0.02)
                .clamp(12.0, 18.0)
                .toDouble();
            final submitSpacing = (screenHeight * 0.03)
                .clamp(18.0, 28.0)
                .toDouble();

            // Keep forms centered and width-limited on larger screens.
            final formWidth = isMobile
                ? double.infinity
                : isTablet
                ? 500.0
                : 560.0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    // Required centered content container for tablet/desktop.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          (screenHeight * 0.03).clamp(16.0, 28.0).toDouble(),
                          horizontalPadding,
                          ((screenHeight * 0.03).clamp(16.0, 28.0) +
                                  keyboardInset)
                              .toDouble(),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: topSpacing),

                                _buildHeader(
                                  context,
                                  isMobile: isMobile,
                                  isDesktop: isDesktop,
                                  textScale: textScale,
                                ),

                                SizedBox(height: betweenSpacing),

                                if (error != null)
                                  _buildError(
                                    context,
                                    error,
                                    width: constraints.maxWidth,
                                    textScale: textScale,
                                  ),

                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _phoneCtr,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          labelText: 'Mobile Number',
                                          prefixText: '+91 ',
                                          prefixIcon: Icon(
                                            Icons.phone_outlined,
                                            size: (screenWidth * 0.05)
                                                .clamp(18.0, 22.0)
                                                .toDouble(),
                                          ),
                                        ),
                                        validator: Validators.phone,
                                      ),

                                      SizedBox(height: fieldSpacing),

                                      TextFormField(
                                        controller: _passCtr,
                                        obscureText: _obscure,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: Icon(
                                            Icons.lock_outlined,
                                            size: (screenWidth * 0.05)
                                                .clamp(18.0, 22.0)
                                                .toDouble(),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscure
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              size: (screenWidth * 0.05)
                                                  .clamp(18.0, 22.0)
                                                  .toDouble(),
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

                                      SizedBox(height: submitSpacing),

                                      SizedBox(
                                        width: double.infinity,
                                        child: AppButton(
                                          label: 'Sign In',
                                          onPressed: _submit,
                                          loading: loading,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildHeader(
    BuildContext context, {
    required bool isMobile,
    required bool isDesktop,
    required double textScale,
  }) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;

    final logoSize = isMobile
        ? (screenWidth * 0.2).clamp(72.0, 84.0).toDouble()
        : isDesktop
        ? (screenWidth * 0.08).clamp(88.0, 104.0).toDouble()
        : (screenWidth * 0.13).clamp(84.0, 96.0).toDouble();
    final logoRadius = isMobile
        ? (screenWidth * 0.05).clamp(20.0, 22.0).toDouble()
        : (screenWidth * 0.03).clamp(22.0, 24.0).toDouble();
    final iconSize = (logoSize * 0.5).clamp(36.0, 48.0).toDouble();
    final headlineSize = isMobile
        ? (30 * textScale).clamp(28.0, 34.0).toDouble()
        : (40 * textScale).clamp(34.0, 44.0).toDouble();
    final subtitleSize = isMobile
        ? (14 * textScale).clamp(13.0, 16.0).toDouble()
        : (18 * textScale).clamp(16.0, 20.0).toDouble();

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: AppColors.therapistGradient,
            borderRadius: BorderRadius.circular(logoRadius),
          ),
          child: Icon(Icons.psychology, color: Colors.white, size: iconSize),
        ),

        SizedBox(height: isMobile ? 16 : 24),

        Text(
          'NaiviSense',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: headlineSize),
        ),

        const SizedBox(height: 8),

        Text(
          'Therapy coordination platform',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: subtitleSize),
        ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    String message, {
    required double width,
    required double textScale,
  }) {
    final marginBottom = (width * 0.02).clamp(12.0, 16.0).toDouble();
    final padding = (width * 0.03).clamp(10.0, 12.0).toDouble();
    final iconSize = (width * 0.045).clamp(16.0, 18.0).toDouble();
    final iconGap = (width * 0.02).clamp(6.0, 8.0).toDouble();
    final radius = (width * 0.03).clamp(10.0, 12.0).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.softCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.softCoral.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.softCoral, size: iconSize),
          SizedBox(width: iconGap),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.softCoral,
                fontSize: (12 * textScale).clamp(11.0, 14.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
