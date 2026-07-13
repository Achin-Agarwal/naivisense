import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/widget/assessment_navigation.dart';
import 'package:naivisense/features/assessments/widget/domain_page.dart';
import 'package:naivisense/features/assessments/widget/review_page.dart';

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

  /// domain_key -> { item_key -> data }
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
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AssessmentResultScreen(assessment: result, child: widget.child),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final state = ref.watch(assessmentSubmitProvider);
    final pageView = PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      children: [
        ...kAssessmentDomains.map(
          (domain) => DomainPage(
            domain: domain,
            data: _domainData[domain.key]!,
            onChanged: (key, value) {

              setState(() {
                _domainData[domain.key]![key] = value;
              });

            },
          ),
        ),
        ReviewPage(
          domainData: _domainData,
          loading: state.loading,
          error: state.error,
          onSubmit: _submit,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          widget.child.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: r.sp(16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(r.h(5, tablet: 6, desktop: 6)),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / (kAssessmentDomains.length + 1),
            backgroundColor: AppColors.divider,
            color: _currentPage < kAssessmentDomains.length
                ? kAssessmentDomains[_currentPage].color
                : AppColors.mintGreen,
            minHeight: r.h(5, tablet: 6, desktop: 6),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                ...kAssessmentDomains.map(
                  (domain) => DomainPage(
                    domain: domain,
                    data: _domainData[domain.key]!,
                    onChanged: (key, value) {
                      setState(() {
                        _domainData[domain.key]![key] = value;
                      });
                    },
                  ),
                ),
                ReviewPage(
                  domainData: _domainData,
                  loading: state.loading,
                  error: state.error,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: AssessmentNavigation(
              loading: state.loading,
              currentPage: _currentPage,
              totalPages: kAssessmentDomains.length + 1,
              onPrevious: _goPrev,
              onNext: _goNext,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
