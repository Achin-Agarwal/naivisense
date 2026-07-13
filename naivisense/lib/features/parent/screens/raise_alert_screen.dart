import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/parent/widget/alert_type_grid.dart';
import 'package:naivisense/features/parent/widget/info_banner.dart';
import 'package:naivisense/features/parent/widget/section_label.dart';
import 'package:naivisense/features/parent/widget/severity_selector.dart';
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

  String _alertType = 'aggression';
  String _severity = 'medium';

  static const _alertTypes = [
    ('fever', Icons.thermostat_outlined, 'Fever'),
    ('regression', Icons.trending_down_outlined, 'Regression'),
    ('aggression', Icons.warning_amber_outlined, 'Aggression'),
    ('seizure', Icons.health_and_safety_outlined, 'Seizure'),
    ('sleep_issue', Icons.bedtime_outlined, 'Sleep Issue'),
    ('injury', Icons.healing_outlined, 'Injury'),
    (
      'emotional_stress',
      Icons.sentiment_dissatisfied_outlined,
      'Emotional Stress',
    ),
    ('other', Icons.more_horiz, 'Other'),
  ];

  static const _severities = [
    ('low', 'Low', AppColors.mintGreen),
    ('medium', 'Medium', AppColors.warmYellow),
    ('high', 'High', AppColors.softCoral),
    // ('critical', 'Critical', Color(0xFFB00020)),
  ];

  @override
  void dispose() {
    _descCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(alertProvider.notifier).submit({
      'child_id': widget.child.id,
      'type': _alertType,
      'description': _descCtr.text.trim(),
      'severity': _severity,
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
    final ui = Responsive(context);
    final alertState = ref.watch(alertProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ui.isMobile;
        final isDesktop = ui.isDesktop;

        final horizontalPadding = ui.horizontalPadding;
        final buttonHeight = ui.sh(isMobile ? 52 : 56);
        final sectionSpacing = ui.sectionSpacing;
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
                    InfoBanner(childName: widget.child.name),

                    SizedBox(height: sectionSpacing),

                    SectionLabel(text: 'Alert Type'),

                    SizedBox(height: ui.sh(12)),

                    AlertTypeGrid(
                      alertTypes: _alertTypes,
                      selectedAlertType: _alertType,
                      onChanged: (value) {
                        setState(() {
                          _alertType = value;
                        });
                      },
                    ),

                    SizedBox(height: sectionSpacing),

                    SectionLabel(text: 'Severity Level'),

                    SizedBox(height: ui.sh(12)),

                    SeveritySelector(
                      severities: _severities,
                      selectedSeverity: _severity,
                      onChanged: (value) {
                        setState(() {
                          _severity = value;
                        });
                      },
                    ),

                    SizedBox(height: sectionSpacing),

                    SectionLabel(text: 'Description'),

                    SizedBox(height: ui.sh(12)),

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
                          fontSize: ui.ssp(isMobile ? 14 : 15),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ui.sRadius(8)),
                          borderSide: const BorderSide(
                            color: AppColors.divider,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ui.sRadius(8)),
                          borderSide: const BorderSide(
                            color: AppColors.divider,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ui.sRadius(8)),
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

                    SizedBox(height: ui.sh(32)),

                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: alertState.loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softCoral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ui.sRadius(8)),
                          ),
                          elevation: 0,
                        ),
                        child: alertState.loading
                            ? SizedBox(
                                width: ui.sIcon(10),
                                height: ui.sIcon(10),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notification_important_outlined,
                                    size: ui.sIcon(isMobile ? 6 : 8),
                                  ),

                                  SizedBox(width: ui.sw(8)),

                                  Text(
                                    'Submit Alert',
                                    style: TextStyle(
                                      fontSize: ui.ssp(isMobile ? 16 : 17),
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

        if (!isMobile) {
          body = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ui.dialogWidth),
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
              style: TextStyle(fontSize: ui.ssp(18)),
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
}
