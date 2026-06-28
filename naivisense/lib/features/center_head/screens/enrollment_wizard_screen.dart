import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/enrollment_provider.dart';

class EnrollmentWizardScreen extends ConsumerStatefulWidget {
  const EnrollmentWizardScreen({super.key});

  @override
  ConsumerState<EnrollmentWizardScreen> createState() =>
      _EnrollmentWizardScreenState();
}

class _EnrollmentWizardScreenState
    extends ConsumerState<EnrollmentWizardScreen> {
  int _step = 0;
  final _formKeys = List.generate(6, (_) => GlobalKey<FormState>());

  // ── Step 1: Identity ─────────────────────────────────────────────────────
  final _nameCtr     = TextEditingController();
  final _nicknameCtr = TextEditingController();
  DateTime? _dob;
  String _gender = 'boy';
  String? _parentId;

  // ── Step 2: Diagnosis ─────────────────────────────────────────────────────
  final _diagnoses = <String>{};
  String _severity = 'mild';
  final _concerns  = <String>{};

  // ── Step 3: Medical history ───────────────────────────────────────────────
  String _birthHistory    = 'normal';
  bool _milestonesDelay   = false;
  bool _hearingIssues     = false;
  bool _visionIssues      = false;
  final _medications      = <String>[];
  final _medCtr           = TextEditingController();
  bool _hadPrevTherapy    = false;
  final _prevTypes        = <String>{};
  int  _prevMonths        = 0;
  final _progressCtr      = TextEditingController();

  // ── Step 4: Functional baseline ──────────────────────────────────────────
  String _commLevel     = 'non_verbal';
  double _attentionMins = 5;
  String _socialLevel   = 'avoids';
  String _motorLevel    = 'low';
  String _behaviorPat   = 'mixed';

  // ── Step 5: Sangat / Home context ────────────────────────────────────────
  final _caregiverCtr = TextEditingController();
  double _screenTime  = 2;
  String _playType    = 'guided';
  String _parentInv   = 'medium';

  // ── Step 6: Goals & Consent ───────────────────────────────────────────────
  final _therapyTargets       = <String>{};
  final _therapistAssignments = <String, String?>{};   // therapy_type → therapist_id
  final _therapistSchedules   = <String, _ScheduleEntry?>{};  // therapy_type → schedule
  final _goalPriorities       = <String>{};
  double _timeline      = 6;
  final _consentByCtr   = TextEditingController();
  bool _consentGiven    = false;

  // ── Constant option lists ─────────────────────────────────────────────────
  static const _diagnosisOpts = [
    'ASD', 'ADHD', 'CP', 'Speech Delay', 'Dyslexia',
    'Down Syndrome', 'Sensory Processing', 'Global Delay', 'Other'
  ];
  static const _concernOpts = [
    'Speech Delay', 'Poor Attention', 'Hyperactivity',
    'Social Issues', 'Motor Difficulty', 'Behavioral Challenges',
    'Feeding Issues', 'Sleep Problems'
  ];
  static const _prevTherapyOpts = [
    'Speech Therapy', 'Occupational Therapy', 'Behavioral Therapy',
    'Physical Therapy', 'Special Education', 'ABA'
  ];
  static const _therapyTargetOpts = [
    'Speech & Language', 'Occupational Therapy', 'Behavioral Therapy',
    'Physical Therapy', 'Special Education', 'Social Skills',
    'Sensory Integration', 'ABA'
  ];
  static const _goalOpts = [
    'Improve Speech', 'Increase Attention', 'Reduce Meltdowns',
    'Social Interaction', 'Eye Contact', 'Self-Care Skills',
    'Academic Readiness', 'Motor Development', 'Emotional Regulation'
  ];

  static const _stepTitles = [
    'Identity',
    'Diagnosis',
    'Medical History',
    'Functional Baseline',
    'Home Context',
    'Goals & Consent',
  ];

  @override
  void dispose() {
    _nameCtr.dispose(); _nicknameCtr.dispose(); _medCtr.dispose();
    _progressCtr.dispose(); _caregiverCtr.dispose(); _consentByCtr.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _next() {
    if (!(_formKeys[_step].currentState?.validate() ?? true)) return;
    if (_step == 5) { _submit(); return; }
    setState(() => _step++);
  }

  void _back() { if (_step > 0) setState(() => _step--); }

  Future<void> _submit() async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'name':             _nameCtr.text.trim(),
      if (_nicknameCtr.text.isNotEmpty) 'nickname': _nicknameCtr.text.trim(),
      'dob':              _dob!.toUtc().toIso8601String(),
      'gender':           _gender,
      'parent_id':        _parentId,
      'therapists': _therapistAssignments.entries
          .where((e) => e.value != null)
          .map((e) {
            final sched = _therapistSchedules[e.key];
            return {
              'therapist_id': e.value!,
              'therapy_type': e.key,
              if (sched != null && sched.days.isNotEmpty) 'schedule': {
                'days':      sched.days,
                'from_time': sched.fromTime,
                'to_time':   sched.toTime,
              },
            };
          })
          .toList(),
      'diagnosis':        _diagnoses.toList(),
      'severity':         _severity,
      'primary_concerns': _concerns.toList(),
      'therapy_targets':  _therapyTargets.toList(),
      'medical': {
        'birth_history':       _birthHistory,
        'milestones_delay':    _milestonesDelay,
        'hearing_issues':      _hearingIssues,
        'vision_issues':       _visionIssues,
        'current_medications': _medications,
      },
      'previous_therapy': {
        'had_therapy':     _hadPrevTherapy,
        'types':           _prevTypes.toList(),
        'duration_months': _prevMonths,
        'progress_noted':  _progressCtr.text.trim(),
      },
      'functional_baseline': {
        'communication_level': _commLevel,
        'attention_span_mins': _attentionMins.round(),
        'social_interaction':  _socialLevel,
        'motor_skills':        _motorLevel,
        'behavior_pattern':    _behaviorPat,
      },
      'home_context': {
        'primary_caregiver':  _caregiverCtr.text.trim(),
        'screen_time_hours':  _screenTime,
        'play_type':          _playType,
        'parent_involvement': _parentInv,
      },
      'goals': {
        'priorities':      _goalPriorities.toList(),
        'timeline_months': _timeline.round(),
      },
      'consent_record': {
        'given_at': now,
        'given_by': _consentByCtr.text.trim(),
      },
    };

    final ok = await ref.read(enrollmentProvider.notifier).submit(payload);
    if (ok && mounted) Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enrollmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Child Enrollment'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKeys[_step],
                child: _buildCurrentStep(),
              ),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(state.error!,
                  style: const TextStyle(color: AppColors.softCoral, fontSize: 13)),
            ),
          _buildNavButtons(state.loading),
        ],
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(6, (i) {
              final done    = i < _step;
              final current = i == _step;
              return Expanded(
                child: Row(
                  children: [
                    _StepDot(index: i + 1, done: done, current: current),
                    if (i < 5)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: done ? AppColors.primaryBlue : AppColors.divider,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Step ${_step + 1} of 6 — ${_stepTitles[_step]}',
            style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Nav buttons ───────────────────────────────────────────────────────────
  Widget _buildNavButtons(bool loading) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: AppButton(
                label: 'Back',
                outlined: true,
                onPressed: _back,
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label:     _step == 5 ? 'Submit Enrollment' : 'Next',
              loading:   loading,
              onPressed: _next,
              icon:      _step == 5 ? Icons.check : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => _buildStep1(),
      1 => _buildStep2(),
      2 => _buildStep3(),
      3 => _buildStep4(),
      4 => _buildStep5(),
      _ => _buildStep6(),
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Identity
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep1() {
    final parents = ref.watch(parentsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Child Identity', Icons.child_care),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameCtr,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nicknameCtr,
          decoration: const InputDecoration(
            labelText: 'Nickname (optional)',
            prefixIcon: Icon(Icons.face_outlined),
          ),
        ),
        const SizedBox(height: 14),
        // DOB picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2018),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _dob = picked);
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Date of Birth *',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                hintText: _dob == null
                    ? 'Tap to select'
                    : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
              ),
              validator: (_) => _dob == null ? 'Select date of birth' : null,
            ),
          ),
        ),
        if (_dob != null) ...[
          const SizedBox(height: 6),
          Text(
            'Age: ${_ageYears(_dob!)} years ${_ageMonths(_dob!)} months',
            style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13),
          ),
        ],
        const SizedBox(height: 20),
        _label('Gender *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['boy', 'girl', 'other'],
          selected: {_gender},
          single: true,
          onTap: (v) => setState(() => _gender = v),
          display: (v) => v[0].toUpperCase() + v.substring(1),
        ),
        const SizedBox(height: 20),
        _label('Parent *'),
        const SizedBox(height: 8),
        parents.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Failed to load parents: $e',
              style: const TextStyle(color: AppColors.softCoral)),
          data: (list) => DropdownButtonFormField<String>(
            initialValue: _parentId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.family_restroom_outlined),
            ),
            hint: const Text('Select parent'),
            items: list.map((u) => DropdownMenuItem(
              value: u.id,
              child: Text('${u.name} (${u.phone})'),
            )).toList(),
            onChanged: (v) => setState(() => _parentId = v),
            validator: (v) => v == null ? 'Select a parent' : null,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Diagnosis & Severity
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Diagnosis & Severity', Icons.medical_information_outlined),
        const SizedBox(height: 16),
        _label('Diagnosis * (select all that apply)'),
        const SizedBox(height: 8),
        _chipGroup(
          options: _diagnosisOpts,
          selected: _diagnoses,
          onTap: (v) => setState(() {
            _diagnoses.contains(v) ? _diagnoses.remove(v) : _diagnoses.add(v);
          }),
          validator: _diagnoses.isEmpty ? 'Select at least one' : null,
        ),
        const SizedBox(height: 20),
        _label('Severity Level *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['mild', 'moderate', 'severe'],
          selected: {_severity},
          single: true,
          onTap: (v) => setState(() => _severity = v),
          display: (v) => switch (v) {
            'mild' => 'Mild',
            'moderate' => 'Moderate',
            _ => 'Severe',
          },
          colors: {
            'mild': AppColors.mintGreen,
            'moderate': AppColors.warmYellow,
            'severe': AppColors.softCoral,
          },
        ),
        const SizedBox(height: 20),
        _label('Primary Concerns (select all that apply)'),
        const SizedBox(height: 8),
        _chipGroup(
          options: _concernOpts,
          selected: _concerns,
          onTap: (v) => setState(() {
            _concerns.contains(v) ? _concerns.remove(v) : _concerns.add(v);
          }),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Medical & Therapy History
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Medical & Therapy History', Icons.history_edu_outlined),
        const SizedBox(height: 16),
        _label('Birth History *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['normal', 'premature', 'complications'],
          selected: {_birthHistory},
          single: true,
          onTap: (v) => setState(() => _birthHistory = v),
          display: (v) => v[0].toUpperCase() + v.substring(1),
        ),
        const SizedBox(height: 20),
        _label('Developmental Flags'),
        const SizedBox(height: 8),
        _switchTile('Developmental milestones delayed', _milestonesDelay,
            (v) => setState(() => _milestonesDelay = v)),
        _switchTile('Known hearing issues', _hearingIssues,
            (v) => setState(() => _hearingIssues = v)),
        _switchTile('Known vision issues', _visionIssues,
            (v) => setState(() => _visionIssues = v)),
        const SizedBox(height: 20),
        _label('Current Medications'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _medCtr,
                decoration: const InputDecoration(
                  hintText: 'Type medication and press Add',
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                final v = _medCtr.text.trim();
                if (v.isNotEmpty) {
                  setState(() { _medications.add(v); _medCtr.clear(); });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        if (_medications.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _medications
                .map((m) => Chip(
                      label: Text(m),
                      onDeleted: () => setState(() => _medications.remove(m)),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 20),
        _switchTile(
          'Child has had previous therapy',
          _hadPrevTherapy,
          (v) => setState(() => _hadPrevTherapy = v),
        ),
        if (_hadPrevTherapy) ...[
          const SizedBox(height: 12),
          _label('Previous Therapy Types'),
          const SizedBox(height: 8),
          _chipGroup(
            options: _prevTherapyOpts,
            selected: _prevTypes,
            onTap: (v) => setState(() {
              _prevTypes.contains(v) ? _prevTypes.remove(v) : _prevTypes.add(v);
            }),
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: _prevMonths > 0 ? '$_prevMonths' : '',
            decoration: const InputDecoration(
              labelText: 'Duration (months)',
              prefixIcon: Icon(Icons.timelapse_outlined),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => _prevMonths = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _progressCtr,
            decoration: const InputDecoration(
              labelText: 'Progress Observed',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 4 — Functional Baseline
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Functional Baseline', Icons.insights_outlined),
        const SizedBox(height: 4),
        const Text(
          'Where the child stands right now — this becomes the baseline for all future progress measurement.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _label('Communication Level *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['non_verbal', 'single_words', 'phrases', 'sentences'],
          selected: {_commLevel},
          single: true,
          onTap: (v) => setState(() => _commLevel = v),
          display: (v) => switch (v) {
            'non_verbal'   => 'Non-Verbal',
            'single_words' => 'Single Words',
            'phrases'      => 'Phrases',
            _              => 'Sentences',
          },
        ),
        const SizedBox(height: 20),
        _label('Attention Span: ${_attentionMins.round()} minutes'),
        Slider(
          value: _attentionMins,
          min: 1, max: 60, divisions: 59,
          activeColor: AppColors.primaryBlue,
          onChanged: (v) => setState(() => _attentionMins = v),
        ),
        const SizedBox(height: 12),
        _label('Social Interaction Quality *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['avoids', 'parallel', 'interactive'],
          selected: {_socialLevel},
          single: true,
          onTap: (v) => setState(() => _socialLevel = v),
          display: (v) => v[0].toUpperCase() + v.substring(1),
        ),
        const SizedBox(height: 20),
        _label('Motor Skills Level *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['low', 'medium', 'age_appropriate'],
          selected: {_motorLevel},
          single: true,
          onTap: (v) => setState(() => _motorLevel = v),
          display: (v) => switch (v) {
            'low'    => 'Low',
            'medium' => 'Medium',
            _        => 'Age Appropriate',
          },
        ),
        const SizedBox(height: 20),
        _label('Behavior Pattern *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['calm', 'challenging', 'mixed'],
          selected: {_behaviorPat},
          single: true,
          onTap: (v) => setState(() => _behaviorPat = v),
          display: (v) => v[0].toUpperCase() + v.substring(1),
          colors: {
            'calm': AppColors.mintGreen,
            'challenging': AppColors.softCoral,
            'mixed': AppColors.warmYellow,
          },
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 5 — Sangat Layer (Home Context)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sangat Layer — Home Context', Icons.home_outlined),
        const SizedBox(height: 4),
        const Text(
          'Home environment directly correlates with therapy outcomes. The AI uses this when generating personalized plans.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _caregiverCtr,
          decoration: const InputDecoration(
            labelText: 'Primary Caregiver *',
            hintText: 'e.g. Mother, Father, Grandparent',
            prefixIcon: Icon(Icons.person_pin_outlined),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        _label('Daily Screen Time: ${_screenTime.toStringAsFixed(1)} hours'),
        Slider(
          value: _screenTime,
          min: 0, max: 12, divisions: 24,
          activeColor: AppColors.primaryBlue,
          onChanged: (v) => setState(() => _screenTime = v),
        ),
        const SizedBox(height: 12),
        _label('Predominant Play Type *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['alone', 'guided', 'group'],
          selected: {_playType},
          single: true,
          onTap: (v) => setState(() => _playType = v),
          display: (v) => v[0].toUpperCase() + v.substring(1),
        ),
        const SizedBox(height: 20),
        _label('Parent Involvement Level *'),
        const SizedBox(height: 8),
        _chipGroup(
          options: const ['low', 'medium', 'high'],
          selected: {_parentInv},
          single: true,
          onTap: (v) => setState(() => _parentInv = v),
          display: (v) => v[0].toUpperCase() + v.substring(1),
          colors: {
            'low':    AppColors.softCoral,
            'medium': AppColors.warmYellow,
            'high':   AppColors.mintGreen,
          },
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 6 — Therapy Targets, Goals & Consent
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep6() {
    final therapists = ref.watch(therapistsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Goals, Targets & Consent', Icons.flag_outlined),
        const SizedBox(height: 16),
        _label('Therapy Focus Areas * (select all that apply)'),
        const SizedBox(height: 8),
        _chipGroup(
          options: _therapyTargetOpts,
          selected: _therapyTargets,
          onTap: (v) => setState(() {
            if (_therapyTargets.contains(v)) {
              _therapyTargets.remove(v);
              _therapistAssignments.remove(v);
            } else {
              _therapyTargets.add(v);
            }
          }),
          validator:
              _therapyTargets.isEmpty ? 'Select at least one target' : null,
        ),
        if (_therapyTargets.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Assign Therapists', Icons.psychology_outlined),
          const SizedBox(height: 4),
          const Text(
            'Optionally assign a therapist for each focus area.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          therapists.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Failed to load therapists: $e',
                style: const TextStyle(color: AppColors.softCoral)),
            data: (list) => Column(
              children: _therapyTargets.map((target) {
                final sched = _therapistSchedules[target];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              target,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _therapistAssignments[target],
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              hint: const Text('Unassigned',
                                  style: TextStyle(fontSize: 13)),
                              items: [
                                const DropdownMenuItem(
                                    value: null,
                                    child: Text('— Unassigned —',
                                        style: TextStyle(fontSize: 13))),
                                ...list.map((u) => DropdownMenuItem(
                                      value: u.id,
                                      child: Text(u.name,
                                          style: const TextStyle(fontSize: 13)),
                                    )),
                              ],
                              onChanged: (v) => setState(
                                  () => _therapistAssignments[target] = v),
                            ),
                          ),
                        ],
                      ),
                      if (_therapistAssignments[target] != null) ...[
                        const SizedBox(height: 10),
                        _buildSchedulePicker(target, sched),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _label('Top Priority Goals (select up to 3)'),
        const SizedBox(height: 8),
        _chipGroup(
          options: _goalOpts,
          selected: _goalPriorities,
          onTap: (v) => setState(() {
            if (_goalPriorities.contains(v)) {
              _goalPriorities.remove(v);
            } else if (_goalPriorities.length < 3) {
              _goalPriorities.add(v);
            }
          }),
        ),
        const SizedBox(height: 20),
        _label('Expected Timeline: ${_timeline.round()} months'),
        Slider(
          value: _timeline,
          min: 1, max: 24, divisions: 23,
          activeColor: AppColors.primaryBlue,
          onChanged: (v) => setState(() => _timeline = v),
        ),
        const SizedBox(height: 20),
        const Divider(),
        _sectionTitle('Consent Record', Icons.verified_user_outlined),
        const SizedBox(height: 12),
        TextFormField(
          controller: _consentByCtr,
          decoration: const InputDecoration(
            labelText: 'Consent Given By *',
            hintText: 'Parent / Guardian name',
            prefixIcon: Icon(Icons.how_to_reg_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        CheckboxListTile(
          value: _consentGiven,
          title: const Text(
            'I confirm that informed consent has been obtained for collecting and processing this child\'s data for therapy coordination purposes.',
            style: TextStyle(fontSize: 13),
          ),
          activeColor: AppColors.primaryBlue,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _consentGiven = v ?? false),
        ),
        if (!_consentGiven)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Consent is required to proceed',
                style: TextStyle(color: AppColors.softCoral, fontSize: 12)),
          ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 22),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
      );

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      activeThumbColor: AppColors.primaryBlue,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }

  Widget _chipGroup({
    required List<String> options,
    required Set<String> selected,
    required void Function(String) onTap,
    bool single = false,
    String Function(String)? display,
    Map<String, Color>? colors,
    String? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            final label = display != null ? display(opt) : opt;
            final color = colors?[opt] ?? AppColors.primaryBlue;
            return GestureDetector(
              onTap: () => onTap(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : AppColors.background,
                  border: Border.all(
                    color: isSelected ? color : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (validator != null) ...[
          const SizedBox(height: 4),
          Text(validator,
              style: const TextStyle(
                  color: AppColors.softCoral, fontSize: 12)),
        ],
      ],
    );
  }

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _dayFullNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  Widget _buildSchedulePicker(String target, _ScheduleEntry? sched) {
    final days      = sched?.days ?? [];
    final fromTime  = sched?.fromTime;
    final toTime    = sched?.toTime;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Session Schedule',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              final selected = days.contains(i);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final updated = List<int>.from(days);
                      selected ? updated.remove(i) : updated.add(i);
                      updated.sort();
                      _therapistSchedules[target] = _ScheduleEntry(
                        days:     updated,
                        fromTime: fromTime ?? '09:00',
                        toTime:   toTime   ?? '10:00',
                      );
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.background,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.divider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (days.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimePickerButton(
                    label: 'From',
                    time: fromTime,
                    onPicked: (t) => setState(() {
                      _therapistSchedules[target] = _ScheduleEntry(
                        days:     days,
                        fromTime: t,
                        toTime:   toTime ?? '10:00',
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TimePickerButton(
                    label: 'To',
                    time: toTime,
                    onPicked: (t) => setState(() {
                      _therapistSchedules[target] = _ScheduleEntry(
                        days:     days,
                        fromTime: fromTime ?? '09:00',
                        toTime:   t,
                      );
                    }),
                  ),
                ),
              ],
            ),
            if (fromTime != null && toTime != null) ...[
              const SizedBox(height: 8),
              Text(
                '${days.map((d) => _dayFullNames[d]).join(', ')}  •  $fromTime – $toTime',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primaryBlue),
              ),
            ],
          ],
        ],
      ),
    );
  }

  int _ageYears(DateTime dob) {
    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  int _ageMonths(DateTime dob) {
    final now = DateTime.now();
    int months = now.month - dob.month;
    if (months < 0) months += 12;
    return months;
  }
}

// ── Schedule entry ────────────────────────────────────────────────────────────
class _ScheduleEntry {
  final List<int> days;
  final String fromTime;
  final String toTime;
  const _ScheduleEntry({required this.days, required this.fromTime, required this.toTime});
}

// ── Time picker button ────────────────────────────────────────────────────────
class _TimePickerButton extends StatelessWidget {
  final String label;
  final String? time;
  final void Function(String) onPicked;
  const _TimePickerButton({required this.label, required this.time, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final parts = time?.split(':');
        final initial = parts != null
            ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))
            : TimeOfDay.now();
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          onPicked(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              time != null ? '$label: $time' : label,
              style: TextStyle(
                fontSize: 13,
                color: time != null ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step dot widget ──────────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  final int index;
  final bool done;
  final bool current;
  const _StepDot(
      {required this.index, required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || current ? AppColors.primaryBlue : AppColors.background,
        border: Border.all(
          color: done || current ? AppColors.primaryBlue : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: current ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
