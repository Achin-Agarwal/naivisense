import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';
import 'package:naivisense/features/assessments/widget/behavioral_item_card.dart';
import 'package:naivisense/features/assessments/widget/score.dart';
import 'package:naivisense/features/assessments/widget/sensory_item_card.dart';
import 'package:naivisense/features/assessments/widget/standard_itemcard.dart';

class DomainPage extends StatelessWidget {
  final AssessmentDomain domain;
  final Map<String, dynamic> data;
  final void Function(String key, dynamic val) onChanged;

  const DomainPage({
    super.key,
    required this.domain,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardMaxWidth = r.isMobile ? double.infinity : 560.0;

        Widget wrapCard(Widget child) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: child,
            ),
          );
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            r.horizontalPadding,
            r.verticalPadding,
            r.horizontalPadding,
            r.h(10, tablet: 12, desktop: 14),
          ),
          children: [
            Builder(
              builder: (_) {
                return wrapCard(
                  Container(
                    padding: r.allPadding(16, tablet: 18, desktop: 20),
                    decoration: BoxDecoration(
                      color: domain.color.withValues(alpha: 0.1),
                      borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
                      border: Border.all(
                        color: domain.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, headerConstraints) {
                        final compact = headerConstraints.maxWidth < 360;
                        final iconChip = Container(
                          padding: r.allPadding(10, tablet: 12, desktop: 14),
                          decoration: BoxDecoration(
                            color: domain.color.withValues(alpha: 0.15),
                            borderRadius: r.borderRadius(
                              10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
                          child: Icon(
                            domain.icon,
                            color: domain.color,
                            size: r.icon(22, tablet: 24, desktop: 26),
                          ),
                        );

                        final textBlock = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              domain.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: domain.color,
                                    fontSize: r.sp(18, tablet: 20, desktop: 22),
                                  ),
                            ),
                            Text(
                              '${domain.items.length} items',
                              style: TextStyle(
                                fontSize: r.sp(12, tablet: 13, desktop: 14),
                                color: domain.color.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        );
                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [iconChip, r.gapH(12), textBlock],
                          );
                        }
                        return Row(
                          children: [
                            iconChip,
                            r.gapW(14),
                            Expanded(child: textBlock),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            if (domain.type == DomainType.standard) ...[
              Builder(
                builder: (_) {
                  return r.gapH(12);
                },
              ),

              Builder(
                builder: (_) {
                  return wrapCard(ScoreLegend(color: domain.color));
                },
              ),

              Builder(
                builder: (_) {
                  return r.gapH(12);
                },
              ),

              ...domain.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return wrapCard(
                  Builder(
                    builder: (_) {

                      return StandardItemCard(
                        item: item,
                        data: data[item.key] as Map<String, dynamic>? ?? {},
                        color: domain.color,
                        onChanged: (value) {

                          onChanged(item.key, value);
                        },
                      );
                    },
                  ),
                );
              }),
            ],

            if (domain.type == DomainType.behavioral) ...[
              Builder(
                builder: (_) {
                  return r.gapH(12);
                },
              ),

              ...domain.items.asMap().entries.map((entry) {
                final item = entry.value;
                return wrapCard(
                  BehavioralItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    onChanged: (val) {
                      onChanged(item.key, val);
                    },
                  ),
                );
              }),
            ],

            if (domain.type == DomainType.sensory) ...[
              Builder(
                builder: (_) {
                  return r.gapH(12);
                },
              ),

              wrapCard(
                Padding(
                  padding: EdgeInsets.only(
                    bottom: r.h(12, tablet: 14, desktop: 16),
                  ),
                  child: Text(
                    'For each sensory modality, select whether the child is Seeking, Avoiding, or Typical, then rate the severity.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),
                ),
              ),

              ...domain.items.asMap().entries.map((entry) {
                final item = entry.value;

                return wrapCard(
                  SensoryItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    color: domain.color,
                    onChanged: (val) {
                      onChanged(item.key, val);
                    },
                  ),
                );
              }),
            ],

            Builder(
              builder: (_) {
                return SizedBox(height: r.h(96, tablet: 110, desktop: 120));
              },
            ),
          ],
        );
      },
    );
  }
}
