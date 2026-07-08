import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/assessment.dart';
import '../../../data/models/child.dart';
import '../data/assessment_domains.dart';

class AssessmentResultScreen extends StatelessWidget {
  final AssessmentModel assessment;
  final ChildModel child;

  const AssessmentResultScreen({
    super.key,
    required this.assessment,
    required this.child,
  });

  Color get _riskColor => switch (assessment.riskLevel) {
    'green' => AppColors.mintGreen,
    'red' => AppColors.softCoral,
    _ => AppColors.warmYellow,
  };

  String get _riskLabel => switch (assessment.riskLevel) {
    'green' => 'Low Risk',
    'red' => 'High Risk',
    _ => 'Moderate Risk',
  };

  String get _riskMessage => switch (assessment.riskLevel) {
    'green' =>
      'The child is performing well overall. Continue current therapy plan.',
    'red' =>
      'Multiple areas need immediate attention. Intensive therapy recommended.',
    _ => 'Some areas need focused intervention. Review therapy goals.',
  };

  @override
  Widget build(BuildContext context) {
    final scores = assessment.domainScores.toKeyedMap();
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints for screen adaptation.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final horizontalPadding = (width * 0.045).clamp(12.0, 24.0).toDouble();
        final sectionSpacing = (width * 0.03).clamp(16.0, 24.0).toDouble();
        final subSectionSpacing = (width * 0.02).clamp(10.0, 14.0).toDouble();
        final appBarIconSize = (width * 0.026).clamp(16.0, 20.0).toDouble();
        final titleFontSize =
            ((isDesktop
                        ? 18.0
                        : isTablet
                        ? 17.0
                        : 16.0) *
                    mediaQuery.textScaler.scale(1.0))
                .clamp(15.0, 20.0)
                .toDouble();
        final sectionTitleSize =
            ((isDesktop
                        ? 19.0
                        : isTablet
                        ? 18.0
                        : 16.0) *
                    mediaQuery.textScaler.scale(1.0))
                .clamp(15.0, 20.0)
                .toDouble();

        final domainCrossAxisCount = isDesktop
            ? 3
            : isTablet
            ? 2
            : 1;
        final domainItemHeight = (width * 0.09).clamp(58.0, 72.0).toDouble();
        final domainGridSpacing = (width * 0.016).clamp(8.0, 14.0).toDouble();

        final content = ListView(
          padding: EdgeInsets.all(horizontalPadding),
          children: [
            // Overall score card
            _buildOverallCard(context, width),
            SizedBox(height: sectionSpacing),

            // Risk level
            _buildRiskCard(context, width),
            SizedBox(height: sectionSpacing),

            // Domain scores
            Text(
              'Domain Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: sectionTitleSize,
              ),
            ),
            SizedBox(height: subSectionSpacing),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAssessmentDomains.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: domainCrossAxisCount,
                crossAxisSpacing: domainGridSpacing,
                mainAxisSpacing: domainGridSpacing,
                mainAxisExtent: domainItemHeight,
              ),
              itemBuilder: (context, index) {
                final domain = kAssessmentDomains[index];
                final score = scores[domain.key] ?? 0;
                return _DomainScoreBar(domain: domain, score: score);
              },
            ),
            SizedBox(height: sectionSpacing),

            // Concern areas
            _buildConcernAreas(context, scores, width),
            SizedBox(height: sectionSpacing),

            // Strength areas
            _buildStrengthAreas(context, scores, width),
            SizedBox(height: (sectionSpacing * 1.3).clamp(24.0, 36.0)),
          ],
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              '${child.name} — Assessment Report',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                icon: Icon(Icons.home_outlined, size: appBarIconSize),
                label: const Text('Home'),
              ),
            ],
          ),
          body: SafeArea(
            // Keep content centered and width-limited for larger screens.
            child: isMobile
                ? content
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: content,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOverallCard(BuildContext context, double width) {
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final cardPadding = (width * 0.06).clamp(18.0, 24.0).toDouble();
    final radius = (width * 0.045).clamp(16.0, 20.0).toDouble();
    final scoreFontSize = (width * 0.12 * textScale)
        .clamp(42.0, 56.0)
        .toDouble();
    final scoreGap = (width * 0.01).clamp(3.0, 6.0).toDouble();
    final smallGap = (width * 0.012).clamp(3.0, 5.0).toDouble();
    final metaGap = (width * 0.02).clamp(10.0, 14.0).toDouble();

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _riskColor.withValues(alpha: 0.9),
            _riskColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Text(
            '${assessment.overallScorePct.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: scoreFontSize,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          SizedBox(height: scoreGap),
          Text(
            'Overall Assessment Score',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: (14 * textScale).clamp(13.0, 16.0),
            ),
          ),
          SizedBox(height: metaGap),
          Text(
            _typeLabel(assessment.type),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: (13 * textScale).clamp(12.0, 15.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: smallGap),
          Text(
            _formatDate(assessment.date),
            style: TextStyle(
              color: Colors.white70,
              fontSize: (12 * textScale).clamp(11.0, 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(BuildContext context, double width) {
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final padding = (width * 0.04).clamp(12.0, 16.0).toDouble();
    final radius = (width * 0.03).clamp(10.0, 14.0).toDouble();
    final iconWrapPadding = (width * 0.025).clamp(8.0, 10.0).toDouble();
    final iconWrapRadius = (width * 0.025).clamp(8.0, 10.0).toDouble();
    final iconSize = (width * 0.04).clamp(18.0, 22.0).toDouble();
    final horizontalGap = (width * 0.03).clamp(10.0, 14.0).toDouble();
    final titleGap = (width * 0.006).clamp(2.0, 4.0).toDouble();

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _riskColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _riskColor.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;

          final iconWidget = Container(
            padding: EdgeInsets.all(iconWrapPadding),
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(iconWrapRadius),
            ),
            child: Icon(_riskIcon, color: _riskColor, size: iconSize),
          );

          final messageWidget = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _riskLabel,
                  style: TextStyle(
                    fontSize: (15 * textScale).clamp(14.0, 17.0),
                    fontWeight: FontWeight.w700,
                    color: _riskColor,
                  ),
                ),
                SizedBox(height: titleGap),
                Text(
                  _riskMessage,
                  style: TextStyle(
                    fontSize: (12 * textScale).clamp(11.0, 14.0),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                SizedBox(height: horizontalGap),
                messageWidget,
              ],
            );
          }

          return Row(
            children: [
              iconWidget,
              SizedBox(width: horizontalGap),
              messageWidget,
            ],
          );
        },
      ),
    );
  }

  Widget _buildConcernAreas(
    BuildContext context,
    Map<String, double> scores,
    double width,
  ) {
    final concerns = kAssessmentDomains
        .where((d) => (scores[d.key] ?? 0) < 40)
        .toList();
    if (concerns.isEmpty) return const SizedBox.shrink();

    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final spacing = (width * 0.016).clamp(8.0, 12.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Areas of Concern',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.softCoral,
            fontSize: (16 * textScale).clamp(15.0, 18.0),
          ),
        ),
        SizedBox(height: spacing),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: concerns
              .map(
                (d) => _AreaChip(
                  label: d.title,
                  color: AppColors.softCoral,
                  icon: d.icon,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStrengthAreas(
    BuildContext context,
    Map<String, double> scores,
    double width,
  ) {
    final strengths = kAssessmentDomains
        .where((d) => (scores[d.key] ?? 0) >= 70)
        .toList();
    if (strengths.isEmpty) return const SizedBox.shrink();

    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final spacing = (width * 0.016).clamp(8.0, 12.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strength Areas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.mintGreen,
            fontSize: (16 * textScale).clamp(15.0, 18.0),
          ),
        ),
        SizedBox(height: spacing),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: strengths
              .map(
                (d) => _AreaChip(
                  label: d.title,
                  color: AppColors.mintGreen,
                  icon: d.icon,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  IconData get _riskIcon => switch (assessment.riskLevel) {
    'green' => Icons.check_circle_outline,
    'red' => Icons.error_outline,
    _ => Icons.warning_amber_outlined,
  };

  String _typeLabel(String t) => switch (t) {
    'initial' => 'Initial Baseline Assessment',
    'monthly' => 'Monthly Reassessment',
    'quarterly' => 'Quarterly Review',
    _ => t,
  };

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
      '${_months[d.month - 1]} '
      '${d.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

// ── Domain Score Bar ──────────────────────────────────────────────────────

class _DomainScoreBar extends StatelessWidget {
  final AssessmentDomain domain;
  final double score;

  const _DomainScoreBar({required this.domain, required this.score});

  Color get _barColor {
    if (score >= 70) return AppColors.mintGreen;
    if (score >= 40) return AppColors.warmYellow;
    return AppColors.softCoral;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final iconSize = (width * 0.028).clamp(16.0, 18.0).toDouble();
    final horizontalGap = (width * 0.012).clamp(6.0, 10.0).toDouble();
    final progressHeight = (width * 0.012).clamp(8.0, 10.0).toDouble();
    final titleSize = (12 * textScale).clamp(11.0, 14.0).toDouble();
    final percentSize = (12 * textScale).clamp(11.0, 14.0).toDouble();
    final progressRadius = (width * 0.01).clamp(5.0, 6.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 280;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(domain.icon, size: iconSize, color: domain.color),
                  SizedBox(width: horizontalGap),
                  Expanded(
                    child: Text(
                      domain.title,
                      style: TextStyle(fontSize: titleSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: horizontalGap),
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: percentSize,
                      fontWeight: FontWeight.w600,
                      color: _barColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: horizontalGap),
              ClipRRect(
                borderRadius: BorderRadius.circular(progressRadius),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: progressHeight,
                  backgroundColor: AppColors.divider,
                  color: _barColor,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: (width * 0.05).clamp(28.0, 32.0),
              child: Icon(domain.icon, size: iconSize, color: domain.color),
            ),
            SizedBox(width: horizontalGap),
            Expanded(
              flex: 3,
              child: Text(
                domain.title,
                style: TextStyle(fontSize: titleSize),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(progressRadius),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: progressHeight,
                  backgroundColor: AppColors.divider,
                  color: _barColor,
                ),
              ),
            ),
            SizedBox(width: horizontalGap),
            SizedBox(
              width: (width * 0.07).clamp(34.0, 42.0),
              child: Text(
                '${score.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: percentSize,
                  fontWeight: FontWeight.w600,
                  color: _barColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _AreaChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final horizontalPadding = (width * 0.015).clamp(8.0, 10.0).toDouble();
    final verticalPadding = (width * 0.01).clamp(5.0, 6.0).toDouble();
    final radius = (width * 0.03).clamp(16.0, 20.0).toDouble();
    final iconSize = (width * 0.02).clamp(11.0, 12.0).toDouble();
    final iconGap = (width * 0.008).clamp(4.0, 5.0).toDouble();
    final fontSize = (11 * textScale).clamp(10.0, 13.0).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(width: iconGap),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
