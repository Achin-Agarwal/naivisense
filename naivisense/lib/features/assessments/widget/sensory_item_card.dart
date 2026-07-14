import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';

class SensoryItemCard extends StatefulWidget {
  final AssessmentItem item;
  final Map<String, dynamic> data;
  final Color color;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SensoryItemCard({
    super.key,
    required this.item,
    required this.data,
    required this.color,
    required this.onChanged,
  });

  @override
  State<SensoryItemCard> createState() => _SensoryItemCardState();
}

class _SensoryItemCardState extends State<SensoryItemCard> {
  late String _pattern;
  late int _severity;
  late TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();

    _pattern = widget.data['pattern'] as String? ?? 'typical';
    _severity = widget.data['severity'] as int? ?? 1;

    _remarksController = TextEditingController(
      text: widget.data['remarks'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged({
      'pattern': _pattern,
      'severity': _severity,
      'remarks': _remarksController.text,
    });
  }

  Color get _patternColor {
    switch (_pattern) {
      case 'seeking':
        return AppColors.warmYellow;
      case 'avoiding':
        return AppColors.softCoral;
      default:
        return AppColors.mintGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: r.h(10)),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.radius(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(r.w(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),

            r.gapH(10, tablet: 12, desktop: 14),

            Wrap(
              spacing: r.w(8),
              runSpacing: r.h(8),
              children: List.generate(kSensoryPatterns.length, (index) {
                final pattern = kSensoryPatterns[index];
                final selected = pattern == _pattern;

                final chipColor = switch (pattern) {
                  'seeking' => AppColors.warmYellow,
                  'avoiding' => AppColors.softCoral,
                  _ => AppColors.mintGreen,
                };

                return InkWell(
                  borderRadius: BorderRadius.circular(r.radius(20)),
                  onTap: () {
                    setState(() => _pattern = pattern);
                    _notify();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: r.w(14),
                      vertical: r.h(8),
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? chipColor
                          : chipColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(r.radius(20)),
                      border: Border.all(
                        color: chipColor.withValues(alpha: .40),
                      ),
                    ),
                    child: Text(
                      kSensoryPatternLabels[index],
                      style: TextStyle(
                        fontSize: r.sp(12),
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : chipColor,
                      ),
                    ),
                  ),
                );
              }),
            ),

            Offstage(
              offstage: _pattern == 'typical',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  r.gapH(12, tablet: 14),

                  Row(
                    children: [
                      Text(
                        'Severity',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_severity / 5',
                        style: TextStyle(
                          color: _patternColor,
                          fontWeight: FontWeight.w600,
                          fontSize: r.sp(13),
                        ),
                      ),
                    ],
                  ),

                  Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: _patternColor,
                    label: '$_severity',
                    onChanged: (value) {
                      setState(() {
                        _severity = value.round();
                      });
                      _notify();
                    },
                  ),
                ],
              ),
            ),

            r.gapH(6),

            TextField(
              controller: _remarksController,
              onChanged: (_) => _notify(),
              style: TextStyle(fontSize: r.sp(13)),
              decoration: InputDecoration(
                hintText: 'Remarks (optional)',
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: r.w(12),
                  vertical: r.h(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.radius(8)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
