import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../data/assessment_domains.dart';
import '../providers/assessment_provider.dart';
import 'assessment_result_screen.dart';

class AssessmentWizardScreen extends ConsumerStatefulWidget {
  final ChildModel child;
  final String assessmentType; // initial | monthly | quarterly
  const AssessmentWizardScreen({
    super.key,
    required this.child,
    required this.assessmentType,
  });

  @override
  ConsumerState<AssessmentWizardScreen> createState() =>
      _AssessmentWizardScreenState();
}

class _AssessmentWizardScreenState
    extends ConsumerState<AssessmentWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // domain_key -> { item_key -> { score, remarks } / behavioral / sensory data }
  final Map<String, Map<String, dynamic>> _domainData = {};

  @override
  void initState() {
    super.initState();
    for (final d in kAssessmentDomains) {
      _domainData[d.key] = {};
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < kAssessmentDomains.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final payload = {
      'child_id': widget.child.id,
      'type': widget.assessmentType,
      'general_notes': '',
      'domain_data': _domainData,
    };

    final result = await ref
        .read(assessmentSubmitProvider.notifier)
        .submit(payload, widget.child.id);

    if (result != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AssessmentResultScreen(
                assessment: result,
                child: widget.child,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentSubmitProvider);
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoints used consistently across this screen.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final appBarTitleSize =
            ((isDesktop
                        ? 20.0
                        : isTablet
                        ? 18.0
                        : 16.0) *
                    mediaQuery.textScaler.scale(1.0))
                .clamp(15.0, 22.0)
                .toDouble();
        final progressHeight = (width * 0.01).clamp(4.0, 6.0).toDouble();

        final pageView = PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: [
            ...kAssessmentDomains.map(
              (domain) => _DomainPage(
                domain: domain,
                data: _domainData[domain.key]!,
                onChanged: (key, val) =>
                    setState(() => _domainData[domain.key]![key] = val),
              ),
            ),
            _ReviewPage(
              domainData: _domainData,
              loading: state.loading,
              error: state.error,
              onSubmit: _submit,
            ),
          ],
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          // Keep keyboard from causing overflow in forms.
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              widget.child.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: appBarTitleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(progressHeight),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / (kAssessmentDomains.length + 1),
                backgroundColor: AppColors.divider,
                color: kAssessmentDomains.length > _currentPage
                    ? kAssessmentDomains[_currentPage].color
                    : AppColors.mintGreen,
                minHeight: progressHeight,
              ),
            ),
          ),
          body: SafeArea(
            // On tablet/desktop, center and constrain content width.
            child: isMobile
                ? pageView
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: pageView,
                    ),
                  ),
          ),
          bottomNavigationBar: _buildNav(
            loading: state.loading,
            width: width,
            isMobile: isMobile,
          ),
        );
      },
    );
  }

  Widget _buildNav({
    required bool loading,
    required double width,
    required bool isMobile,
  }) {
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final isLast = _currentPage == kAssessmentDomains.length;
    final hPadding = (width * 0.03).clamp(12.0, 16.0).toDouble();
    final vPaddingTop = (width * 0.015).clamp(6.0, 8.0).toDouble();
    final vPaddingBottom = (width * 0.03).clamp(12.0, 16.0).toDouble();
    final counterSize = (12 * textScale).clamp(11.0, 14.0).toDouble();

    final navContent = LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_currentPage + 1} / ${kAssessmentDomains.length + 1}',
                style: TextStyle(
                  fontSize: counterSize,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: (width * 0.015).clamp(6.0, 10.0)),
              Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: _currentPage > 0 ? 1.0 : 0.0,
                      child: _NavButton(
                        label: 'Back',
                        icon: Icons.arrow_back,
                        outlined: true,
                        onTap: (!loading && _currentPage > 0) ? _goPrev : null,
                      ),
                    ),
                  ),
                  SizedBox(width: (width * 0.02).clamp(8.0, 12.0)),
                  Expanded(
                    child: _NavButton(
                      label: isLast ? 'Submit' : 'Next',
                      icon: isLast
                          ? (loading ? Icons.hourglass_top : Icons.check)
                          : Icons.arrow_forward,
                      outlined: false,
                      onTap: loading ? null : (isLast ? _submit : _goNext),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Always render both buttons so layout and mouse regions stay stable.
        return Row(
          children: [
            Opacity(
              opacity: _currentPage > 0 ? 1.0 : 0.0,
              child: _NavButton(
                label: 'Back',
                icon: Icons.arrow_back,
                outlined: true,
                onTap: (!loading && _currentPage > 0) ? _goPrev : null,
              ),
            ),
            const Spacer(),
            Text(
              '${_currentPage + 1} / ${kAssessmentDomains.length + 1}',
              style: TextStyle(
                fontSize: counterSize,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            _NavButton(
              label: isLast ? 'Submit' : 'Next',
              icon: isLast
                  ? (loading ? Icons.hourglass_top : Icons.check)
                  : Icons.arrow_forward,
              outlined: false,
              onTap: loading ? null : (isLast ? _submit : _goNext),
            ),
          ],
        );
      },
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          hPadding,
          vPaddingTop,
          hPadding,
          vPaddingBottom,
        ),
        child: isMobile
            ? navContent
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: navContent,
                ),
              ),
      ),
    );
  }
}

// -- Domain Page ------------------------------------------------------------

class _DomainPage extends StatelessWidget {
  final AssessmentDomain domain;
  final Map<String, dynamic> data;
  final void Function(String key, dynamic val) onChanged;

  const _DomainPage({
    required this.domain,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final isMobile = width < 600;
        final cardMaxWidth = isMobile ? double.infinity : 560.0;

        final pagePadding = EdgeInsets.fromLTRB(
          (width * 0.03).clamp(12.0, 16.0),
          (width * 0.03).clamp(12.0, 16.0),
          (width * 0.03).clamp(12.0, 16.0),
          (width * 0.015).clamp(8.0, 10.0),
        );

        final headerPadding = (width * 0.035).clamp(14.0, 18.0).toDouble();
        final headerRadius = (width * 0.03).clamp(12.0, 14.0).toDouble();
        final iconWrapPadding = (width * 0.02).clamp(8.0, 10.0).toDouble();
        final iconWrapRadius = (width * 0.025).clamp(8.0, 10.0).toDouble();
        final iconSize = (width * 0.045).clamp(20.0, 24.0).toDouble();
        final sectionGap = (width * 0.02).clamp(8.0, 12.0).toDouble();

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
          padding: pagePadding,
          children: [
            // Responsive header that avoids overflow on narrow screens.
            wrapCard(
              Container(
                padding: EdgeInsets.all(headerPadding),
                decoration: BoxDecoration(
                  color: domain.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(headerRadius),
                  border: Border.all(
                    color: domain.color.withValues(alpha: 0.25),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, headerConstraints) {
                    final compact = headerConstraints.maxWidth < 360;
                    final titleStyle = Theme.of(context).textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: domain.color,
                        );

                    final iconChip = Container(
                      padding: EdgeInsets.all(iconWrapPadding),
                      decoration: BoxDecoration(
                        color: domain.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(iconWrapRadius),
                      ),
                      child: Icon(
                        domain.icon,
                        color: domain.color,
                        size: iconSize,
                      ),
                    );

                    final textBlock = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          domain.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                        Text(
                          '${domain.items.length} items',
                          style: TextStyle(
                            fontSize: (12 * mediaQuery.textScaler.scale(1.0))
                                .clamp(11.0, 14.0),
                            color: domain.color.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconChip,
                          SizedBox(height: sectionGap),
                          textBlock,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        iconChip,
                        SizedBox(width: (width * 0.025).clamp(10.0, 14.0)),
                        Expanded(child: textBlock),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (domain.type == DomainType.standard) ...[
              SizedBox(height: sectionGap),
              wrapCard(_ScoreLegend(color: domain.color)),
              SizedBox(height: (width * 0.02).clamp(10.0, 12.0)),
              ...domain.items.map(
                (item) => wrapCard(
                  _StandardItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    color: domain.color,
                    onChanged: (val) => onChanged(item.key, val),
                  ),
                ),
              ),
            ] else if (domain.type == DomainType.behavioral) ...[
              SizedBox(height: (width * 0.02).clamp(10.0, 12.0)),
              ...domain.items.map(
                (item) => wrapCard(
                  _BehavioralItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    onChanged: (val) => onChanged(item.key, val),
                  ),
                ),
              ),
            ] else if (domain.type == DomainType.sensory) ...[
              SizedBox(height: sectionGap),
              wrapCard(
                Padding(
                  padding: EdgeInsets.only(
                    bottom: (width * 0.02).clamp(10.0, 12.0),
                  ),
                  child: Text(
                    'For each sensory modality, select whether the child is Seeking, Avoiding, or Typical, then rate the severity.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              ...domain.items.map(
                (item) => wrapCard(
                  _SensoryItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    color: domain.color,
                    onChanged: (val) => onChanged(item.key, val),
                  ),
                ),
              ),
            ],
            SizedBox(height: (width * 0.18).clamp(72.0, 96.0)),
          ],
        );
      },
    );
  }
}

// -- Score Legend -----------------------------------------------------------

class _ScoreLegend extends StatelessWidget {
  final Color color;
  const _ScoreLegend({required this.color});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemH = (width * 0.025).clamp(8.0, 10.0).toDouble();
    final itemV = (width * 0.01).clamp(4.0, 5.0).toDouble();
    final radius = (width * 0.03).clamp(16.0, 20.0).toDouble();

    return Wrap(
      spacing: (width * 0.02).clamp(8.0, 10.0).toDouble(),
      runSpacing: (width * 0.015).clamp(6.0, 8.0).toDouble(),
      children: List.generate(
        4,
        (i) => Container(
          padding: EdgeInsets.symmetric(horizontal: itemH, vertical: itemV),
          decoration: BoxDecoration(
            color: kScoreColors[i].withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: kScoreColors[i].withValues(alpha: 0.4)),
          ),
          child: Text(
            '$i - ${kScoreLabels[i]}',
            style: TextStyle(
              fontSize: (11 * MediaQuery.of(context).textScaler.scale(1.0))
                  .clamp(10.0, 13.0),
              fontWeight: FontWeight.w600,
              color: kScoreColors[i],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Standard Item Card -----------------------------------------------------

class _StandardItemCard extends StatefulWidget {
  final AssessmentItem item;
  final Map<String, dynamic> data;
  final Color color;
  final void Function(Map<String, dynamic>) onChanged;

  const _StandardItemCard({
    required this.item,
    required this.data,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_StandardItemCard> createState() => _StandardItemCardState();
}

class _StandardItemCardState extends State<_StandardItemCard> {
  late int? _score;
  late TextEditingController _remarksCtrl;

  @override
  void initState() {
    super.initState();
    _score = widget.data['score'] as int?;
    _remarksCtrl = TextEditingController(
      text: widget.data['remarks'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _notify() =>
      widget.onChanged({'score': _score ?? 0, 'remarks': _remarksCtrl.text});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);

    final marginBottom = (width * 0.02).clamp(8.0, 10.0).toDouble();
    final radius = (width * 0.03).clamp(10.0, 12.0).toDouble();
    final padding = (width * 0.03).clamp(12.0, 14.0).toDouble();
    final titleSize = (14 * textScale).clamp(13.0, 16.0).toDouble();
    final scoreChipWidth = (width * 0.11).clamp(40.0, 44.0).toDouble();
    final scoreChipHeight = (width * 0.09).clamp(34.0, 36.0).toDouble();

    return Card(
      margin: EdgeInsets.only(bottom: marginBottom),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.label,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: (width * 0.02).clamp(8.0, 10.0)),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;
                final chips = List.generate(4, (i) {
                  final selected = _score == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _score = i);
                      _notify();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: scoreChipWidth,
                      height: scoreChipHeight,
                      decoration: BoxDecoration(
                        color: selected
                            ? kScoreColors[i]
                            : kScoreColors[i].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          (width * 0.02).clamp(7.0, 8.0),
                        ),
                        border: Border.all(
                          color: kScoreColors[i].withValues(
                            alpha: selected ? 1 : 0.35,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$i',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: (15 * textScale).clamp(13.0, 16.0),
                            color: selected ? Colors.white : kScoreColors[i],
                          ),
                        ),
                      ),
                    ),
                  );
                });

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: (width * 0.02).clamp(6.0, 8.0).toDouble(),
                        runSpacing: (width * 0.02).clamp(6.0, 8.0).toDouble(),
                        children: chips,
                      ),
                      if (_score != null) ...[
                        SizedBox(height: (width * 0.015).clamp(6.0, 8.0)),
                        Text(
                          kScoreLabels[_score!],
                          style: TextStyle(
                            fontSize: (12 * textScale).clamp(11.0, 14.0),
                            color: kScoreColors[_score!],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Wrap(
                      spacing: (width * 0.02).clamp(6.0, 8.0).toDouble(),
                      children: chips,
                    ),
                    if (_score != null) ...[
                      SizedBox(width: (width * 0.02).clamp(8.0, 10.0)),
                      Expanded(
                        child: Text(
                          kScoreLabels[_score!],
                          style: TextStyle(
                            fontSize: (12 * textScale).clamp(11.0, 14.0),
                            color: kScoreColors[_score!],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: (width * 0.02).clamp(8.0, 10.0)),
            TextField(
              controller: _remarksCtrl,
              onChanged: (_) => _notify(),
              style: TextStyle(fontSize: (12 * textScale).clamp(11.0, 14.0)),
              decoration: InputDecoration(
                hintText: 'Therapist remarks (optional)',
                hintStyle: TextStyle(
                  fontSize: (12 * textScale).clamp(11.0, 14.0),
                  color: AppColors.textSecondary,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: (width * 0.025).clamp(9.0, 10.0),
                  vertical: (width * 0.02).clamp(7.0, 8.0),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    (width * 0.02).clamp(7.0, 8.0),
                  ),
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

// -- Behavioral Item Card ---------------------------------------------------

class _BehavioralItemCard extends StatefulWidget {
  final AssessmentItem item;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic>) onChanged;

  const _BehavioralItemCard({
    required this.item,
    required this.data,
    required this.onChanged,
  });

  @override
  State<_BehavioralItemCard> createState() => _BehavioralItemCardState();
}

class _BehavioralItemCardState extends State<_BehavioralItemCard> {
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
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final radius = (width * 0.03).clamp(10.0, 12.0).toDouble();
    final padding = (width * 0.03).clamp(12.0, 14.0).toDouble();

    return Card(
      margin: EdgeInsets.only(bottom: (width * 0.02).clamp(8.0, 10.0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      elevation: 0,
      color: _present
          ? AppColors.softCoral.withValues(alpha: 0.06)
          : AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;
                final label = Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: (14 * textScale).clamp(13.0, 16.0),
                    fontWeight: FontWeight.w600,
                  ),
                );

                final switchBlock = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: (width * 0.0023).clamp(0.8, 0.9),
                      child: Switch(
                        value: _present,
                        onChanged: (v) {
                          setState(() => _present = v);
                          _notify();
                        },
                        activeThumbColor: AppColors.softCoral,
                      ),
                    ),
                    Text(
                      _present ? 'Present' : 'Absent',
                      style: TextStyle(
                        fontSize: (12 * textScale).clamp(11.0, 14.0),
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
                    children: [
                      label,
                      SizedBox(height: (width * 0.015).clamp(6.0, 8.0)),
                      switchBlock,
                    ],
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
            // Keep always in tree (Offstage) so Slider's MouseRegion is never
            // removed while hovered.
            Offstage(
              offstage: !_present,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (width * 0.025).clamp(10.0, 12.0)),
                  Text(
                    'Frequency',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: (width * 0.015).clamp(5.0, 6.0)),
                  Wrap(
                    spacing: (width * 0.02).clamp(6.0, 8.0).toDouble(),
                    runSpacing: (width * 0.015).clamp(6.0, 8.0).toDouble(),
                    children: kBehaviorFrequencies.map((f) {
                      final sel = _frequency == f;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _frequency = f);
                          _notify();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: (width * 0.03).clamp(10.0, 12.0),
                            vertical: (width * 0.015).clamp(5.0, 6.0),
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.softCoral
                                : AppColors.softCoral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              (width * 0.05).clamp(16.0, 20.0),
                            ),
                            border: Border.all(
                              color: AppColors.softCoral.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _capitalize(f),
                            style: TextStyle(
                              fontSize: (12 * textScale).clamp(11.0, 14.0),
                              fontWeight: FontWeight.w500,
                              color: sel ? Colors.white : AppColors.softCoral,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: (width * 0.02).clamp(8.0, 10.0)),
                  Wrap(
                    spacing: (width * 0.01).clamp(4.0, 6.0).toDouble(),
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Intensity: ',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_intensity/5',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.softCoral,
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
                      setState(() => _intensity = v.round());
                      _notify();
                    },
                  ),
                  SizedBox(height: (width * 0.01).clamp(3.0, 4.0)),
                  TextField(
                    controller: _triggersCtrl,
                    onChanged: (_) => _notify(),
                    style: TextStyle(
                      fontSize: (12 * textScale).clamp(11.0, 14.0),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Triggers / context (optional)',
                      hintStyle: TextStyle(
                        fontSize: (12 * textScale).clamp(11.0, 14.0),
                        color: AppColors.textSecondary,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: (width * 0.025).clamp(9.0, 10.0),
                        vertical: (width * 0.02).clamp(7.0, 8.0),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          (width * 0.02).clamp(7.0, 8.0),
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

// -- Sensory Item Card ------------------------------------------------------

class _SensoryItemCard extends StatefulWidget {
  final AssessmentItem item;
  final Map<String, dynamic> data;
  final Color color;
  final void Function(Map<String, dynamic>) onChanged;

  const _SensoryItemCard({
    required this.item,
    required this.data,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_SensoryItemCard> createState() => _SensoryItemCardState();
}

class _SensoryItemCardState extends State<_SensoryItemCard> {
  late String _pattern;
  late int _severity;
  late TextEditingController _remarksCtrl;

  @override
  void initState() {
    super.initState();
    _pattern = widget.data['pattern'] as String? ?? 'typical';
    _severity = widget.data['severity'] as int? ?? 1;
    _remarksCtrl = TextEditingController(
      text: widget.data['remarks'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged({
    'pattern': _pattern,
    'severity': _severity,
    'remarks': _remarksCtrl.text,
  });

  Color get _patternColor => switch (_pattern) {
    'seeking' => AppColors.warmYellow,
    'avoiding' => AppColors.softCoral,
    _ => AppColors.mintGreen,
  };

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);

    return Card(
      margin: EdgeInsets.only(bottom: (width * 0.02).clamp(8.0, 10.0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((width * 0.03).clamp(10.0, 12.0)),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all((width * 0.03).clamp(12.0, 14.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.label,
              style: TextStyle(
                fontSize: (14 * textScale).clamp(13.0, 16.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: (width * 0.02).clamp(8.0, 10.0)),
            Wrap(
              spacing: (width * 0.02).clamp(6.0, 8.0).toDouble(),
              runSpacing: (width * 0.015).clamp(6.0, 8.0).toDouble(),
              children: List.generate(3, (i) {
                final pattern = kSensoryPatterns[i];
                final sel = _pattern == pattern;
                final color = switch (pattern) {
                  'seeking' => AppColors.warmYellow,
                  'avoiding' => AppColors.softCoral,
                  _ => AppColors.mintGreen,
                };
                return GestureDetector(
                  onTap: () {
                    setState(() => _pattern = pattern);
                    _notify();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: (width * 0.035).clamp(12.0, 14.0),
                      vertical: (width * 0.017).clamp(6.0, 7.0),
                    ),
                    decoration: BoxDecoration(
                      color: sel ? color : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        (width * 0.05).clamp(16.0, 20.0),
                      ),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      kSensoryPatternLabels[i],
                      style: TextStyle(
                        fontSize: (12 * textScale).clamp(11.0, 14.0),
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : color,
                      ),
                    ),
                  ),
                );
              }),
            ),
            // Keep always in tree so Slider's MouseRegion is never removed.
            Offstage(
              offstage: _pattern == 'typical',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (width * 0.02).clamp(8.0, 10.0)),
                  Wrap(
                    spacing: (width * 0.01).clamp(4.0, 6.0).toDouble(),
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Severity: ',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_severity/5',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _patternColor,
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
                    onChanged: (v) {
                      setState(() => _severity = v.round());
                      _notify();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: (width * 0.01).clamp(3.0, 4.0)),
            TextField(
              controller: _remarksCtrl,
              onChanged: (_) => _notify(),
              style: TextStyle(fontSize: (12 * textScale).clamp(11.0, 14.0)),
              decoration: InputDecoration(
                hintText: 'Remarks (optional)',
                hintStyle: TextStyle(
                  fontSize: (12 * textScale).clamp(11.0, 14.0),
                  color: AppColors.textSecondary,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: (width * 0.025).clamp(9.0, 10.0),
                  vertical: (width * 0.02).clamp(7.0, 8.0),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    (width * 0.02).clamp(7.0, 8.0),
                  ),
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

// -- Review Page ------------------------------------------------------------

class _ReviewPage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> domainData;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  const _ReviewPage({
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
    } else if (domain.type == DomainType.sensory) {
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
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final hPadding = (width * 0.03).clamp(12.0, 16.0).toDouble();
        final sectionGap = (width * 0.03).clamp(16.0, 20.0).toDouble();
        final gridGap = (width * 0.02).clamp(8.0, 12.0).toDouble();
        final crossAxisCount = isDesktop
            ? 3
            : isTablet
            ? 2
            : 1;

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.all(hPadding),
          children: [
            Container(
              padding: EdgeInsets.all((width * 0.04).clamp(16.0, 20.0)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CD7A2), Color(0xFF2AAD7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  (width * 0.04).clamp(14.0, 16.0),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: (width * 0.1).clamp(32.0, 40.0),
                  ),
                  SizedBox(height: (width * 0.02).clamp(8.0, 12.0)),
                  Text(
                    'Review & Submit',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize:
                          ((isDesktop
                                      ? 24.0
                                      : isTablet
                                      ? 22.0
                                      : 20.0) *
                                  mediaQuery.textScaler.scale(1.0))
                              .clamp(18.0, 26.0)
                              .toDouble(),
                    ),
                  ),
                  SizedBox(height: (width * 0.01).clamp(3.0, 4.0)),
                  Text(
                    'Review domain completion before submitting',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: (13 * mediaQuery.textScaler.scale(1.0)).clamp(
                        12.0,
                        15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAssessmentDomains.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: gridGap,
                mainAxisSpacing: gridGap,
                mainAxisExtent: (width * 0.18).clamp(82.0, 98.0).toDouble(),
              ),
              itemBuilder: (context, index) {
                final domain = kAssessmentDomains[index];
                final filled = _scoredItems(
                  domainData[domain.key] ?? {},
                  domain,
                );
                final total = domain.items.length;
                final pct = total > 0 ? filled / total : 0.0;

                return Container(
                  padding: EdgeInsets.all((width * 0.022).clamp(8.0, 12.0)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      (width * 0.02).clamp(8.0, 10.0),
                    ),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all((width * 0.02).clamp(7.0, 8.0)),
                        decoration: BoxDecoration(
                          color: domain.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            (width * 0.02).clamp(7.0, 8.0),
                          ),
                        ),
                        child: Icon(
                          domain.icon,
                          size: (width * 0.03).clamp(14.0, 16.0),
                          color: domain.color,
                        ),
                      ),
                      SizedBox(width: (width * 0.02).clamp(8.0, 12.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              domain.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    (13 * mediaQuery.textScaler.scale(1.0))
                                        .clamp(12.0, 14.0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: (width * 0.01).clamp(3.0, 4.0)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                (width * 0.01).clamp(3.0, 4.0),
                              ),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: (width * 0.008).clamp(4.0, 5.0),
                                backgroundColor: AppColors.divider,
                                color: domain.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: (width * 0.015).clamp(6.0, 10.0)),
                      Text(
                        '$filled/$total',
                        style: TextStyle(
                          fontSize: (12 * mediaQuery.textScaler.scale(1.0))
                              .clamp(11.0, 14.0),
                          fontWeight: FontWeight.w600,
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
            if (error != null) ...[
              SizedBox(height: (width * 0.03).clamp(14.0, 16.0)),
              Container(
                padding: EdgeInsets.all((width * 0.03).clamp(10.0, 12.0)),
                decoration: BoxDecoration(
                  color: AppColors.softCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    (width * 0.025).clamp(8.0, 10.0),
                  ),
                  border: Border.all(
                    color: AppColors.softCoral.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  error!,
                  style: const TextStyle(color: AppColors.softCoral),
                ),
              ),
            ],
            SizedBox(height: (width * 0.18).clamp(72.0, 96.0)),
          ],
        );
      },
    );
  }
}

// -- Nav Button -------------------------------------------------------------

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final color = outlined ? AppColors.textSecondary : AppColors.primaryBlue;

    final iconSize = (width * 0.03).clamp(14.0, 16.0).toDouble();
    final labelSize = (14 * textScale).clamp(13.0, 16.0).toDouble();
    final hPadding = (width * 0.045).clamp(14.0, 20.0).toDouble();
    final vPadding = (width * 0.027).clamp(10.0, 12.0).toDouble();
    final radius = (width * 0.03).clamp(10.0, 12.0).toDouble();
    final iconGap = (width * 0.015).clamp(5.0, 6.0).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: vPadding,
          ),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(radius),
            border: outlined
                ? Border.all(color: color.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (outlined) ...[
                Icon(icon, size: iconSize, color: color),
                SizedBox(width: iconGap),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : Colors.white,
                ),
              ),
              if (!outlined) ...[
                SizedBox(width: iconGap),
                Icon(icon, size: iconSize, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
