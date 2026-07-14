import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';

class ReviewPage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> domainData;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  const ReviewPage({
    super.key,
    required this.domainData,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  int _scoredItems(Map<String, dynamic> data, AssessmentDomain domain) {
    if (domain.type == DomainType.behavioral) {
      return data.values
          .whereType<Map>()
          .where((v) => v.containsKey('present'))
          .length;
    }

    if (domain.type == DomainType.sensory) {
      return data.values
          .whereType<Map>()
          .where((v) => v.containsKey('pattern'))
          .length;
    }

    return data.values
        .whereType<Map>()
        .where((v) => v.containsKey('score'))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final crossAxisCount = r.isDesktop
        ? 3
        : r.isTablet
        ? 2
        : 1;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.maxWidth),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: r.allPadding(16, tablet: 24, desktop: 28),
          children: [
            //---------------------------------------------------------
            // Header
            //---------------------------------------------------------
            Container(
              padding: r.allPadding(18, tablet: 22, desktop: 26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CD7A2), Color(0xFF2AAD7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: r.icon(34, tablet: 38, desktop: 42),
                  ),

                  r.gapH(10, tablet: 12, desktop: 14),

                  Text(
                    "Review & Submit",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: r.sp(20, tablet: 22, desktop: 24),
                    ),
                  ),

                  r.gapH(4),

                  Text(
                    "Review domain completion before submitting",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: r.sp(13, tablet: 14, desktop: 15),
                    ),
                  ),
                ],
              ),
            ),

            r.gapH(20, tablet: 24, desktop: 28),

            //---------------------------------------------------------
            // Grid
            //---------------------------------------------------------
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAssessmentDomains.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: r.w(10, tablet: 12, desktop: 14),
                mainAxisSpacing: r.h(10, tablet: 12, desktop: 14),
                mainAxisExtent: r.h(90, tablet: 94, desktop: 100),
              ),
              itemBuilder: (context, index) {
                final domain = kAssessmentDomains[index];

                final filled = _scoredItems(
                  domainData[domain.key] ?? {},
                  domain,
                );

                final total = domain.items.length;

                final double pct = total == 0 ? 0.0 : filled / total;

                return Container(
                  padding: r.allPadding(10, tablet: 12, desktop: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: r.borderRadius(10, tablet: 12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: r.allPadding(8),
                        decoration: BoxDecoration(
                          color: domain.color.withValues(alpha: 0.12),
                          borderRadius: r.borderRadius(8),
                        ),
                        child: Icon(
                          domain.icon,
                          color: domain.color,
                          size: r.icon(16, tablet: 18, desktop: 20),
                        ),
                      ),

                      r.gapW(10),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              domain.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.sp(13, tablet: 14, desktop: 15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            r.gapH(4),

                            ClipRRect(
                              borderRadius: r.borderRadius(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: r.h(4),
                                backgroundColor: AppColors.divider,
                                color: domain.color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      r.gapW(8),

                      Text(
                        "$filled/$total",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: r.sp(12),
                          color: pct >= 1
                              ? AppColors.mintGreen
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            //---------------------------------------------------------
            // Error
            //---------------------------------------------------------
            if (error != null) ...[
              r.gapH(18),

              Container(
                padding: r.allPadding(12, tablet: 14),
                decoration: BoxDecoration(
                  color: AppColors.softCoral.withValues(alpha: 0.1),
                  borderRadius: r.borderRadius(10),
                  border: Border.all(
                    color: AppColors.softCoral.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: AppColors.softCoral,
                    fontSize: r.sp(13),
                  ),
                ),
              ),
            ],

            r.gapH(90, tablet: 100, desktop: 110),
          ],
        ),
      ),
    );
  }
}
