// -- Behavioral Item Card ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';

class BehavioralItemCard extends StatefulWidget {
  final AssessmentItem item;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic>) onChanged;

  const BehavioralItemCard({
    super.key,
    required this.item,
    required this.data,
    required this.onChanged,
  });

  @override
  State<BehavioralItemCard> createState() => BehavioralItemCardState();
}

class BehavioralItemCardState extends State<BehavioralItemCard> {
  late bool _present;
  late String _frequency;
  late int _intensity;
  late TextEditingController _triggersCtrl;

  @override
  void initState() {
    super.initState();
    _present = widget.data['present'] as bool? ?? false;
    _frequency = widget.data['frequency'] as String? ?? 'weekly';
    _intensity = widget.data['intensity'] as int? ?? 3;
    _triggersCtrl = TextEditingController(
      text: widget.data['triggers'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _triggersCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged({
    'present': _present,
    if (_present) ...{
      'frequency': _frequency,
      'intensity': _intensity,
      'triggers': _triggersCtrl.text,
    },
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Card(
      margin: EdgeInsets.only(bottom: r.h(10, tablet: 12, desktop: 14)),
      shape: RoundedRectangleBorder(
        borderRadius: r.borderRadius(12, tablet: 14, desktop: 16),
      ),
      elevation: 0,
      color: _present
          ? AppColors.softCoral.withValues(alpha: 0.06)
          : AppColors.surface,
      child: Padding(
        padding: r.allPadding(14, tablet: 16, desktop: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                final label = Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.w600,
                  ),
                );

                final switchBlock = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: r.w(0.85, tablet: 0.9, desktop: 1),
                      child: Switch(
                        value: _present,
                        activeThumbColor: AppColors.softCoral,
                        onChanged: (v) {
                          setState(() => _present = v);
                          _notify();
                        },
                      ),
                    ),
                    Text(
                      _present ? 'Present' : 'Absent',
                      style: TextStyle(
                        fontSize: r.sp(12, tablet: 13, desktop: 14),
                        fontWeight: FontWeight.w500,
                        color: _present
                            ? AppColors.softCoral
                            : AppColors.mintGreen,
                      ),
                    ),
                  ],
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [label, r.gapH(8), switchBlock],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: label),
                    switchBlock,
                  ],
                );
              },
            ),

            Offstage(
              offstage: !_present,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  r.gapH(12),

                  Text(
                    'Frequency',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  r.gapH(6),

                  Wrap(
                    spacing: r.w(8, tablet: 10, desktop: 12),
                    runSpacing: r.h(8, tablet: 10, desktop: 12),
                    children: kBehaviorFrequencies.map((f) {
                      final sel = _frequency == f;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _frequency = f);
                          _notify();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.w(12, tablet: 14, desktop: 16),
                            vertical: r.h(6, tablet: 7, desktop: 8),
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.softCoral
                                : AppColors.softCoral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              r.radius(20, tablet: 22, desktop: 24),
                            ),
                            border: Border.all(
                              color: AppColors.softCoral.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _capitalize(f),
                            style: TextStyle(
                              fontSize: r.sp(12, tablet: 13, desktop: 14),
                              fontWeight: FontWeight.w500,
                              color: sel ? Colors.white : AppColors.softCoral,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  r.gapH(10),

                  Wrap(
                    spacing: r.w(6),
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Intensity:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_intensity/5',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.softCoral,
                          fontSize: r.sp(13, tablet: 14, desktop: 15),
                        ),
                      ),
                    ],
                  ),

                  Slider(
                    value: _intensity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: AppColors.softCoral,
                    label: '$_intensity',
                    onChanged: (v) {
                      if (_intensity != v.round()) {
                        setState(() {
                          _intensity = v.round();
                        });
                      }
                    },
                    onChangeEnd: (_) {
                      _notify();
                    },
                  ),

                  r.gapH(4),

                  TextField(
                    controller: _triggersCtrl,
                    onChanged: (_) => _notify(),
                    style: TextStyle(
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Triggers / context (optional)',
                      hintStyle: TextStyle(
                        fontSize: r.sp(12, tablet: 13, desktop: 14),
                        color: AppColors.textSecondary,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: r.w(10, tablet: 12, desktop: 14),
                        vertical: r.h(8, tablet: 10, desktop: 12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: r.borderRadius(
                          8,
                          tablet: 10,
                          desktop: 12,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
