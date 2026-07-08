import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../providers/parent_provider.dart';

class RaiseAlertScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const RaiseAlertScreen({super.key, required this.child});

  @override
  ConsumerState<RaiseAlertScreen> createState() => _RaiseAlertScreenState();
}

class _RaiseAlertScreenState extends ConsumerState<RaiseAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtr = TextEditingController();

  String _alertType = 'behavioral';
  String _severity = 'medium';

  static const _alertTypes = [
    ('behavioral', Icons.psychology_outlined, 'Behavioral'),
    ('medical', Icons.local_hospital_outlined, 'Medical'),
    ('emotional', Icons.favorite_border, 'Emotional'),
    ('academic', Icons.menu_book_outlined, 'Academic'),
    ('social', Icons.group_outlined, 'Social'),
    ('other', Icons.more_horiz, 'Other'),
  ];

  static const _severities = [
    ('low', 'Low', AppColors.mintGreen),
    ('medium', 'Medium', AppColors.warmYellow),
    ('high', 'High', AppColors.softCoral),
    ('critical', 'Critical', Color(0xFFB00020)),
  ];

  @override
  void dispose() {
    _descCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(alertProvider.notifier).submit({
      'childId': widget.child.id,
      'type': _alertType,
      'severity': _severity,
      'description': _descCtr.text.trim(),
    });

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert raised successfully'),
          backgroundColor: AppColors.mintGreen,
        ),
      );

      context.pop();
    } else {
      final err = ref.read(alertProvider).error ?? 'Failed to raise alert';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.softCoral),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;

        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        final isDesktop = constraints.maxWidth >= 1024;

        // Responsive values
        final horizontalPadding = isMobile ? 20.0 : 28.0;

        final buttonHeight = isMobile ? 52.0 : 56.0;

        final sectionSpacing = isMobile ? 24.0 : 28.0;

        final formMaxWidth = isDesktop ? 600.0 : 700.0;

        Widget body = Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(horizontalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBanner(isMobile),

                    SizedBox(height: sectionSpacing),

                    _sectionLabel(context, 'Alert Type'),

                    const SizedBox(height: 12),

                    _buildAlertTypeGrid(),

                    SizedBox(height: sectionSpacing),

                    _sectionLabel(context, 'Severity Level'),

                    const SizedBox(height: 12),

                    _buildSeverityRow(),

                    SizedBox(height: sectionSpacing),

                    _sectionLabel(context, 'Description'),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descCtr,
                      maxLines: 5,
                      maxLength: 500,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText:
                            'Describe what happened, when it started, '
                            'any patterns you noticed…',

                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isMobile ? 14 : 15,
                        ),

                        filled: true,
                        fillColor: AppColors.surface,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.divider,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.divider,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Please provide at least 10 characters'
                          : null,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: alertState.loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softCoral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: alertState.loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notification_important_outlined,
                                    size: isMobile ? 20 : 22,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    'Submit Alert',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Center screen content on tablet/desktop
        if (!isMobile) {
          body = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: body,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          resizeToAvoidBottomInset: true,

          appBar: AppBar(
            title: Text(
              'Raise Alert — ${widget.child.name}',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: BackButton(onPressed: () => context.pop()),
          ),

          body: SafeArea(child: body),
        );
      },
    );
  }

  Widget _buildInfoBanner(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: isMobile ? 20 : 22,
          ),

          SizedBox(width: isMobile ? 10 : 12),

          Expanded(
            child: Text(
              'Alerts are sent directly to ${widget.child.name}\'s therapy team. '
              'For medical emergencies, please call emergency services immediately.',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: AppColors.primaryBlue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        // Responsive grid columns
        final crossAxisCount = isMobile
            ? 2
            : isTablet
            ? 3
            : 4;

        final iconSize = isMobile ? 24.0 : 28.0;
        final labelFontSize = isMobile ? 12.0 : 13.0;
        final spacing = isMobile ? 10.0 : 12.0;
        final childAspectRatio = isMobile ? 1.15 : 1.25;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _alertTypes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final (val, icon, label) = _alertTypes[index];
            final selected = _alertType == val;

            return GestureDetector(
              onTap: () => setState(() => _alertType = val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.divider,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSeverityRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        // Use Wrap instead of Row to avoid overflow
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _severities.map((s) {
            final (val, label, color) = s;
            final selected = _severity == val;

            return SizedBox(
              width: isMobile
                  ? (constraints.maxWidth - 8) / 2
                  : (constraints.maxWidth - 24) / 4,
              child: GestureDetector(
                onTap: () => setState(() => _severity = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 14,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? color : AppColors.divider,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isMobile ? 10 : 12,
                        height: isMobile ? 10 : 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 600;

    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: isMobile ? 16 : 18,
      ),
    );
  }
}
