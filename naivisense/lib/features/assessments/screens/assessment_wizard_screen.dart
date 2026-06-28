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

  // domain_key → { item_key → { score, remarks } / behavioral / sensory data }
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
      'child_id':     widget.child.id,
      'type':         widget.assessmentType,
      'general_notes': '',
      'domain_data':  _domainData,
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
                child:      widget.child,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.child.name),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / (kAssessmentDomains.length + 1),
            backgroundColor: AppColors.divider,
            color: kAssessmentDomains.length > _currentPage
                ? kAssessmentDomains[_currentPage].color
                : AppColors.mintGreen,
            minHeight: 6,
          ),
        ),
      ),
      body: PageView(
        controller:  _pageController,
        physics:     const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          // Domain pages
          ...kAssessmentDomains.map((domain) => _DomainPage(
                domain:   domain,
                data:     _domainData[domain.key]!,
                onChanged: (key, val) =>
                    setState(() => _domainData[domain.key]![key] = val),
              )),
          // Review page
          _ReviewPage(
            domainData: _domainData,
            loading:    state.loading,
            error:      state.error,
            onSubmit:   _submit,
          ),
        ],
      ),
      bottomNavigationBar: _buildNav(state.loading),
    );
  }

  Widget _buildNav(bool loading) {
    final isLast = _currentPage == kAssessmentDomains.length;

    // Always render both buttons — Opacity maintains layout so the widget
    // tree stays stable and mouse tracking never breaks (hasSize stays true).
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            // Back button — always in tree, invisible on page 0
            Opacity(
              opacity: _currentPage > 0 ? 1.0 : 0.0,
              child: _NavButton(
                label:    'Back',
                icon:     Icons.arrow_back,
                outlined: true,
                onTap:    (!loading && _currentPage > 0) ? _goPrev : null,
              ),
            ),
            const Spacer(),
            Text(
              '${_currentPage + 1} / ${kAssessmentDomains.length + 1}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            // Action button — always in tree, label/icon animated
            _NavButton(
              label: isLast ? 'Submit' : 'Next',
              icon:  isLast
                  ? (loading ? Icons.hourglass_top : Icons.check)
                  : Icons.arrow_forward,
              outlined: false,
              onTap:    loading ? null : (isLast ? _submit : _goNext),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Domain Page ───────────────────────────────────────────────────────────

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        // Domain header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: domain.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: domain.color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        domain.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(domain.icon, color: domain.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: domain.color,
                          ),
                    ),
                    Text(
                      '${domain.items.length} items',
                      style: TextStyle(
                          fontSize: 12,
                          color:    domain.color.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (domain.type == DomainType.standard) ...[
          const SizedBox(height: 8),
          // Score legend
          _ScoreLegend(color: domain.color),
          const SizedBox(height: 12),
          ...domain.items.map((item) => _StandardItemCard(
                item:      item,
                data:      data[item.key] as Map<String, dynamic>? ?? {},
                color:     domain.color,
                onChanged: (val) => onChanged(item.key, val),
              )),
        ] else if (domain.type == DomainType.behavioral) ...[
          const SizedBox(height: 12),
          ...domain.items.map((item) => _BehavioralItemCard(
                item:      item,
                data:      data[item.key] as Map<String, dynamic>? ?? {},
                onChanged: (val) => onChanged(item.key, val),
              )),
        ] else if (domain.type == DomainType.sensory) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'For each sensory modality, select whether the child is Seeking, Avoiding, or Typical, then rate the severity.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ...domain.items.map((item) => _SensoryItemCard(
                item:      item,
                data:      data[item.key] as Map<String, dynamic>? ?? {},
                color:     domain.color,
                onChanged: (val) => onChanged(item.key, val),
              )),
        ],

        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Score Legend ──────────────────────────────────────────────────────────

class _ScoreLegend extends StatelessWidget {
  final Color color;
  const _ScoreLegend({required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(4, (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        kScoreColors[i].withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: kScoreColors[i].withValues(alpha: 0.4)),
            ),
            child: Text(
              '$i – ${kScoreLabels[i]}',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: kScoreColors[i],
              ),
            ),
          ),
        )),
      ),
    );
  }
}

// ── Standard Item Card ────────────────────────────────────────────────────

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
        text: widget.data['remarks'] as String? ?? '');
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged({
        'score':   _score ?? 0,
        'remarks': _remarksCtrl.text,
      });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            // Score chips
            Row(
              children: [
                ...List.generate(4, (i) {
                  final selected = _score == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _score = i);
                        _notify();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected
                              ? kScoreColors[i]
                              : kScoreColors[i].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kScoreColors[i]
                                  .withValues(alpha: selected ? 1 : 0.35)),
                        ),
                        child: Center(
                          child: Text(
                            '$i',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:   15,
                              color: selected
                                  ? Colors.white
                                  : kScoreColors[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (_score != null)
                  Expanded(
                    child: Text(
                      kScoreLabels[_score!],
                      style: TextStyle(
                          fontSize: 12,
                          color:    kScoreColors[_score!],
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _remarksCtrl,
              onChanged:  (_) => _notify(),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText:    'Therapist remarks (optional)',
                hintStyle:   const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                filled:    true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:   BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Behavioral Item Card ──────────────────────────────────────────────────

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
    _present   = widget.data['present'] as bool? ?? false;
    _frequency = widget.data['frequency'] as String? ?? 'weekly';
    _intensity = widget.data['intensity'] as int? ?? 3;
    _triggersCtrl = TextEditingController(
        text: widget.data['triggers'] as String? ?? '');
  }

  @override
  void dispose() {
    _triggersCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged({
        'present':   _present,
        if (_present) ...{
          'frequency': _frequency,
          'intensity': _intensity,
          'triggers':  _triggersCtrl.text,
        },
      });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: _present
          ? AppColors.softCoral.withValues(alpha: 0.06)
          : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value:    _present,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _present
                          ? AppColors.softCoral
                          : AppColors.mintGreen),
                ),
              ],
            ),
            // Keep always in tree (Offstage) so Slider's MouseRegion is never
            // removed while hovered — prevents mouse_tracker.dart:199.
            Offstage(
              offstage: !_present,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Frequency
                  Text('Frequency',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: kBehaviorFrequencies.map((f) {
                      final sel = _frequency == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _frequency = f);
                            _notify();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.softCoral
                                  : AppColors.softCoral.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.softCoral
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              _capitalize(f),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.softCoral),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // Intensity
                  Row(
                    children: [
                      Text('Intensity: ',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textSecondary)),
                      Text(
                        '$_intensity/5',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.softCoral),
                      ),
                    ],
                  ),
                  Slider(
                    value:    _intensity.toDouble(),
                    min:      1,
                    max:      5,
                    divisions: 4,
                    activeColor: AppColors.softCoral,
                    label:    '$_intensity',
                    onChanged: (v) {
                      setState(() => _intensity = v.round());
                      _notify();
                    },
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _triggersCtrl,
                    onChanged:  (_) => _notify(),
                    style:  const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Triggers / context (optional)',
                      hintStyle: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      isDense:  true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled:   true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:   BorderSide.none,
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

// ── Sensory Item Card ─────────────────────────────────────────────────────

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
    _pattern  = widget.data['pattern'] as String? ?? 'typical';
    _severity = widget.data['severity'] as int? ?? 1;
    _remarksCtrl = TextEditingController(
        text: widget.data['remarks'] as String? ?? '');
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged({
        'pattern':  _pattern,
        'severity': _severity,
        'remarks':  _remarksCtrl.text,
      });

  Color get _patternColor => switch (_pattern) {
        'seeking'  => AppColors.warmYellow,
        'avoiding' => AppColors.softCoral,
        _          => AppColors.mintGreen,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                final pattern = kSensoryPatterns[i];
                final sel     = _pattern == pattern;
                final color   = switch (pattern) {
                  'seeking'  => AppColors.warmYellow,
                  'avoiding' => AppColors.softCoral,
                  _          => AppColors.mintGreen,
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _pattern = pattern);
                      _notify();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color:        sel ? color : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        kSensoryPatternLabels[i],
                        style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : color),
                      ),
                    ),
                  ),
                );
              }),
            ),
            // Keep always in tree so Slider's MouseRegion is never removed
            // while hovered — prevents mouse_tracker.dart:199.
            Offstage(
              offstage: _pattern == 'typical',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Severity: ',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textSecondary)),
                      Text('$_severity/5',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _patternColor)),
                    ],
                  ),
                  Slider(
                    value:     _severity.toDouble(),
                    min:       1,
                    max:       5,
                    divisions: 4,
                    activeColor: _patternColor,
                    label:     '$_severity',
                    onChanged: (v) {
                      setState(() => _severity = v.round());
                      _notify();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _remarksCtrl,
              onChanged:  (_) => _notify(),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText:  'Remarks (optional)',
                hintStyle: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                isDense:   true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                filled:    true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:   BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Review Page ───────────────────────────────────────────────────────────

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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CD7A2), Color(0xFF2AAD7E)],
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.assignment_turned_in,
                  color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                'Review & Submit',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review domain completion before submitting',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...kAssessmentDomains.map((domain) {
          final filled  = _scoredItems(domainData[domain.key] ?? {}, domain);
          final total   = domain.items.length;
          final pct     = total > 0 ? filled / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:        domain.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(domain.icon, size: 16, color: domain.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        domain.title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:           pct,
                          minHeight:       5,
                          backgroundColor: AppColors.divider,
                          color:           domain.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$filled/$total',
                  style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color:      pct >= 1
                          ? AppColors.mintGreen
                          : AppColors.textSecondary),
                ),
              ],
            ),
          );
        }),
        if (error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        AppColors.softCoral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.softCoral.withValues(alpha: 0.3)),
            ),
            child: Text(error!,
                style: const TextStyle(color: AppColors.softCoral)),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Nav Button ────────────────────────────────────────────────────────────

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
    final color = outlined ? AppColors.textSecondary : AppColors.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(12),
            border: outlined ? Border.all(color: color.withValues(alpha: 0.4)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (outlined) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : Colors.white,
                ),
              ),
              if (!outlined) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
