import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../../../shared/widgets/trend_chart.dart';
import '../providers/reports_provider.dart';

class WeeklyReportScreen extends ConsumerWidget {
  final String childId;
  final String childName;

  const WeeklyReportScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    final params = ReportParams(childId: childId, from: from, to: now);
    final report = ref.watch(progressReportProvider(params));

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              '$childName — Progress Report',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: report.when(
            loading: () => const sw.LoadingWidget(),
            error: (e, _) => sw.ErrorWidget(message: e.toString()),
            data: (r) {
              Widget content = _ReportBody(
                report: r,
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
              );

              // Center and constrain content on tablet/desktop
              if (!isMobile) {
                content = Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: content,
                  ),
                );
              }

              return content;
            },
          ),
        );
      },
    );
  }
}

class _ReportBody extends StatelessWidget {
  final ProgressReport report;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _ReportBody({
    required this.report,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Responsive spacing
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalSpacing = isMobile ? 20.0 : 24.0;

    final ratings = report.sessions
        .map<double>((s) => ((s['rating'] as num?) ?? 0).toDouble())
        .toList();

    final labels = List.generate(ratings.length, (i) => 'S${i + 1}');

    return ListView(
      padding: EdgeInsets.all(horizontalPadding),
      children: [
        _SummaryRow(
          sessionCount: report.totalSessions,
          avgRating: report.avgRating,
          compliancePct: report.compliancePct,
          isMobile: isMobile,
          isTablet: isTablet,
          screenWidth: mediaQuery.size.width,
        ),
        SizedBox(height: verticalSpacing),
        if (ratings.isNotEmpty)
          AppCard(
            child: TrendChart(
              title: 'Session Ratings',
              values: ratings,
              labels: labels,
            ),
          ),
        SizedBox(height: verticalSpacing),
        AppCard(
          child: _ComplianceBar(pct: report.compliancePct, isMobile: isMobile),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int sessionCount;
  final double avgRating;
  final double compliancePct;
  final bool isMobile;
  final bool isTablet;
  final double screenWidth;

  const _SummaryRow({
    required this.sessionCount,
    required this.avgRating,
    required this.compliancePct,
    required this.isMobile,
    required this.isTablet,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Use Wrap instead of Row to prevent overflow on smaller screens
    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: (screenWidth - 44) / 2,
            child: _KpiCard(
              label: 'Sessions',
              value: '$sessionCount',
              isMobile: isMobile,
            ),
          ),
          SizedBox(
            width: (screenWidth - 44) / 2,
            child: _KpiCard(
              label: 'Avg Rating',
              value: avgRating.toStringAsFixed(1),
              isMobile: isMobile,
            ),
          ),
          SizedBox(
            width: screenWidth - 32,
            child: _KpiCard(
              label: 'Compliance',
              value: '${compliancePct.round()}%',
              isMobile: isMobile,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Sessions',
            value: '$sessionCount',
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Avg Rating',
            value: avgRating.toStringAsFixed(1),
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Compliance',
            value: '${compliancePct.round()}%',
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Responsive typography
    final valueFontSize = isMobile
        ? mediaQuery.size.width * 0.06
        : mediaQuery.size.width * 0.025;

    final paddingVertical = isMobile ? 16.0 : 20.0;
    final paddingHorizontal = isMobile ? 12.0 : 16.0;

    return AppCard(
      padding: EdgeInsets.symmetric(
        vertical: paddingVertical,
        horizontal: paddingHorizontal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontSize: valueFontSize.clamp(24.0, 36.0),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ComplianceBar extends StatelessWidget {
  final double pct;
  final bool isMobile;

  const _ComplianceBar({required this.pct, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final color = pct >= 70
        ? AppColors.mintGreen
        : pct >= 40
        ? AppColors.warmYellow
        : AppColors.softCoral;

    // Responsive values
    final spacing = isMobile ? 12.0 : 16.0;
    final progressHeight = isMobile ? 12.0 : 14.0;

    final titleFontSize = isMobile
        ? mediaQuery.textScaler.scale(20)
        : mediaQuery.textScaler.scale(24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Home Plan Compliance',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: titleFontSize),
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  minHeight: progressHeight,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            SizedBox(width: spacing),
            FittedBox(
              child: Text(
                '${pct.round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
