import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/schedule_entry.dart';
import 'package:naivisense/features/center_head/widgets/field_label.dart';
import 'package:naivisense/features/center_head/widgets/horizontal_options.dart';
import 'package:naivisense/features/center_head/widgets/schedule_picker.dart';
import 'package:naivisense/features/center_head/widgets/section_title.dart';
import 'package:naivisense/features/center_head/widgets/selectable_card_group.dart';
import 'package:naivisense/features/center_head/widgets/severity_card.dart';
import 'package:naivisense/features/center_head/widgets/step_indicator2.dart';
import 'package:naivisense/features/center_head/widgets/step_navigation_buttons2.dart';
import 'package:naivisense/features/center_head/widgets/therapist_dropdown.dart';
import '../../../core/theme/app_colors.dart';
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

  final _nameCtr = TextEditingController();
  final _nicknameCtr = TextEditingController();
  DateTime? _dob;
  String _gender = '';
  String? _parentId;

  final _diagnoses = <String>{};
  String _severity = 'mild';
  final _concerns = <String>{};

  String _birthHistory = 'normal';
  bool _milestonesDelay = false;
  bool _hearingIssues = false;
  bool _visionIssues = false;
  final _medications = <String>[];
  final _medCtr = TextEditingController();
  bool _hadPrevTherapy = false;
  final _prevTypes = <String>{};
  int _prevMonths = 0;
  final _progressCtr = TextEditingController();

  String _commLevel = 'non_verbal';
  double _attentionMins = 5;
  String _socialLevel = 'avoids';
  String _motorLevel = 'low';
  String _behaviorPat = 'mixed';

  final _caregiverCtr = TextEditingController();
  double _screenTime = 2;
  String _playType = 'guided';
  String _parentInv = 'medium';

  final _therapyTargets = <String>{};
  final _therapistAssignments = <String, String?>{};
  final _therapistSchedules = <String, ScheduleEntry?>{};
  final Map<String, String> _sessionModes = {};
  final _goalPriorities = <String>{};
  double _timeline = 6;
  final _consentByCtr = TextEditingController();
  bool _consentGiven = false;

  static const _diagnosisOpts = [
    'ASD',
    'ADHD',
    'CP',
    'Speech Delay',
    'Dyslexia',
    'Down Syndrome',
    'Sensory Processing',
    'Global Delay',
    'Other',
  ];
  static const _concernOpts = [
    'Speech Delay',
    'Poor Attention',
    'Hyperactivity',
    'Social Issues',
    'Motor Difficulty',
    'Behavioral Challenges',
    'Feeding Issues',
    'Sleep Problems',
  ];
  static const _prevTherapyOpts = [
    'Speech Therapy',
    'Occupational Therapy',
    'Behavioral Therapy',
    'Physical Therapy',
    'Special Education',
    'ABA',
  ];
  static const _therapyTargetOpts = [
    'Speech & Language',
    'Occupational Therapy',
    'Behavioral Therapy',
    'Physical Therapy',
    'Special Education',
    'Social Skills',
    'Sensory Integration',
    'ABA',
  ];
  static const _goalOpts = [
    'Improve Speech',
    'Increase Attention',
    'Reduce Meltdowns',
    'Social Interaction',
    'Eye Contact',
    'Self-Care Skills',
    'Academic Readiness',
    'Motor Development',
    'Emotional Regulation',
  ];

  late double w;
  late double h;
  late bool isMobile;
  late bool isTablet;
  late bool isDesktop;

  void _initResponsive(BoxConstraints constraints, BuildContext context) {
    w = constraints.maxWidth;
    h = constraints.maxHeight;

    isMobile = w < 600;
    isTablet = w >= 600 && w < 1024;
    isDesktop = w >= 1024;
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _nicknameCtr.dispose();
    _medCtr.dispose();
    _progressCtr.dispose();
    _caregiverCtr.dispose();
    _consentByCtr.dispose();
    super.dispose();
  }

  void _next() {
    if (!(_formKeys[_step].currentState?.validate() ?? true)) return;
    if (_step == 5) {
      _submit();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    // Validate therapist schedules
    for (final entry in _therapistAssignments.entries) {
      if (entry.value == null) continue;

      final sched = _therapistSchedules[entry.key];

      if (sched == null ||
          sched.days.isEmpty ||
          sched.fromTime.isEmpty ||
          sched.toTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete the schedule for "${entry.key}".'),
            backgroundColor: AppColors.softCoral,
          ),
        );
        return;
      }
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final payload = {
      'name': _nameCtr.text.trim(),

      if (_nicknameCtr.text.isNotEmpty) 'nickname': _nicknameCtr.text.trim(),

      'dob': _dob!.toUtc().toIso8601String(),
      'gender': _gender,
      'parent_id': _parentId,

      'therapists': _therapistAssignments.entries
          .where((e) => e.value != null)
          .map((e) {
            final sched = _therapistSchedules[e.key];

            return {
              'therapist_id': e.value!,
              'therapy_type': e.key,

              // Backend now expects an ARRAY of schedules
              'schedule': [
                {
                  'enrollment_mode': _sessionModes[e.key] ?? 'offline',

                  'days': sched!.days,
                  'from_time': sched.fromTime,
                  'to_time': sched.toTime,
                },
              ],
            };
          })
          .toList(),

      'diagnosis': _diagnoses.toList(),

      'severity': _severity,

      'primary_concerns': _concerns.toList(),

      'therapy_targets': _therapyTargets.toList(),

      'medical': {
        'birth_history': _birthHistory,
        'milestones_delay': _milestonesDelay,
        'hearing_issues': _hearingIssues,
        'vision_issues': _visionIssues,
        'current_medications': _medications,
      },

      'previous_therapy': {
        'had_therapy': _hadPrevTherapy,
        'types': _prevTypes.toList(),
        'duration_months': _prevMonths,
        'progress_noted': _progressCtr.text.trim(),
      },

      'functional_baseline': {
        'communication_level': _commLevel,
        'attention_span_mins': _attentionMins.round(),
        'social_interaction': _socialLevel,
        'motor_skills': _motorLevel,
        'behavior_pattern': _behaviorPat,
      },

      'home_context': {
        'primary_caregiver': _caregiverCtr.text.trim(),
        'screen_time_hours': _screenTime,
        'play_type': _playType,
        'parent_involvement': _parentInv,
      },

      'goals': {
        'priorities': _goalPriorities.toList(),
        'timeline_months': _timeline.round(),
      },

      'consent_record': {
        'given_at': now,
        'given_by': _consentByCtr.text.trim(),
      },
    };

    final ok = await ref.read(enrollmentProvider.notifier).submit(payload);

    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enrollmentProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        _initResponsive(constraints, context);

        final scale = isMobile
            ? 1.0
            : isTablet
            ? 1.1
            : 1.25;

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
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  StepIndicator(
                    currentStep: _step,
                    stepTitles: const [
                      'Child Information',
                      'Family Background',
                      'Medical History',
                      'Functional Assessment',
                      'Home Context',
                      'Goals & Consent',
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20 * scale),
                      child: Form(
                        key: _formKeys[_step],
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * scale,
                        vertical: 4,
                      ),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: AppColors.softCoral,
                          fontSize: 13 * scale,
                        ),
                      ),
                    ),
                  StepNavigationButtons(
                    currentStep: _step,
                    loading: state.loading,
                    onBack: _back,
                    onNext: _next,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildStep1() {
    final ui = Responsive(context);
    final parents = ref.watch(parentsProvider);

    final fieldSpacing = ui.sh(ui.isMobile ? 14 : 18);

    // Smaller icons on desktop, slightly larger on mobile
    final iconSize = ui.isDesktop ? ui.sIcon(8) : ui.sIcon(20);

    Widget twoCol(Widget a, Widget b) {
      if (ui.isMobile) {
        return Column(
          children: [
            a,
            SizedBox(height: fieldSpacing),
            b,
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: a),
          SizedBox(width: fieldSpacing),
          Expanded(child: b),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: 'Child Identity', icon: Icons.child_care),

        SizedBox(height: fieldSpacing),

        twoCol(
          TextFormField(
            controller: _nameCtr,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: ui.ssp(14)),
            decoration: InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person_outline, size: iconSize),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ui.sRadius(12)),
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter child name' : null,
          ),

          TextFormField(
            controller: _nicknameCtr,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: ui.ssp(14)),
            decoration: InputDecoration(
              labelText: 'Nickname (Optional)',
              prefixIcon: Icon(Icons.face_outlined, size: iconSize),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ui.sRadius(12)),
              ),
            ),
          ),
        ),

        SizedBox(height: fieldSpacing),

        ui.isMobile
            ? Column(
                children: [
                  // DOB
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();

                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dob ?? DateTime(2018),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setState(() => _dob = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: _dob == null
                                ? ''
                                : '${_dob!.day.toString().padLeft(2, '0')}/'
                                      '${_dob!.month.toString().padLeft(2, '0')}/'
                                      '${_dob!.year}',
                          ),
                          style: TextStyle(fontSize: ui.ssp(14)),
                          decoration: InputDecoration(
                            labelText: 'Date of Birth *',
                            hintText: 'Select Date of Birth',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: iconSize,
                            ),
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ui.sRadius(12),
                              ),
                            ),
                          ),
                          validator: (_) =>
                              _dob == null ? 'Select date of birth' : null,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: fieldSpacing),

                  // Gender
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender.isEmpty ? null : _gender,
                      style: TextStyle(fontSize: ui.ssp(14)),
                      decoration: InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.wc_outlined, size: iconSize),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ui.sRadius(12)),
                        ),
                      ),
                      hint: const Text('Select Gender'),
                      items: const [
                        DropdownMenuItem(value: 'boy', child: Text('Boy')),
                        DropdownMenuItem(value: 'girl', child: Text('Girl')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? ''),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Select gender' : null,
                    ),
                  ),

                  SizedBox(height: fieldSpacing),

                  // Parent
                  parents.when(
                    loading: () => const LinearProgressIndicator(),

                    error: (e, _) => Text(
                      'Failed to load parents: $e',
                      style: TextStyle(
                        color: AppColors.softCoral,
                        fontSize: ui.ssp(13),
                      ),
                    ),

                    data: (list) => MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: DropdownButtonFormField<String>(
                        initialValue: _parentId,
                        style: TextStyle(fontSize: ui.ssp(14)),
                        decoration: InputDecoration(
                          labelText: 'Parent *',
                          prefixIcon: Icon(
                            Icons.family_restroom_outlined,
                            size: iconSize,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ui.sRadius(12)),
                          ),
                        ),
                        hint: const Text('Select Parent'),
                        items: list
                            .map(
                              (u) => DropdownMenuItem(
                                value: u.id,
                                child: Text(
                                  '${u.name} (${u.phone})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _parentId = v),
                        validator: (v) => v == null ? 'Select a parent' : null,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dob ?? DateTime(2018),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );

                              if (picked != null) {
                                setState(() => _dob = picked);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: _dob == null
                                      ? ''
                                      : '${_dob!.day.toString().padLeft(2, '0')}/'
                                            '${_dob!.month.toString().padLeft(2, '0')}/'
                                            '${_dob!.year}',
                                ),
                                style: TextStyle(fontSize: ui.ssp(14)),
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth *',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    size: iconSize,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      ui.sRadius(12),
                                    ),
                                  ),
                                ),
                                validator: (_) => _dob == null
                                    ? 'Select date of birth'
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: fieldSpacing),

                      Expanded(
                        flex: 2,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: DropdownButtonFormField<String>(
                            initialValue: _gender.isEmpty ? null : _gender,
                            style: TextStyle(fontSize: ui.ssp(14)),
                            decoration: InputDecoration(
                              labelText: 'Gender *',
                              prefixIcon: Icon(
                                Icons.wc_outlined,
                                size: iconSize,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ui.sRadius(12),
                                ),
                              ),
                            ),
                            hint: const Text("Select Gender"),
                            items: const [
                              DropdownMenuItem(
                                value: 'boy',
                                child: Text('Boy'),
                              ),
                              DropdownMenuItem(
                                value: 'girl',
                                child: Text('Girl'),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _gender = v ?? ''),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Select gender' : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: fieldSpacing),

                  parents.when(
                    loading: () => const LinearProgressIndicator(),

                    error: (e, _) => Text(
                      'Failed to load parents',
                      style: TextStyle(color: AppColors.softCoral),
                    ),

                    data: (list) => MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: DropdownButtonFormField<String>(
                        initialValue: _parentId,
                        style: TextStyle(fontSize: ui.ssp(14)),
                        decoration: InputDecoration(
                          labelText: 'Parent *',
                          prefixIcon: Icon(
                            Icons.family_restroom_outlined,
                            size: iconSize,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ui.sRadius(12)),
                          ),
                        ),
                        hint: const Text("Select Parent"),
                        items: list
                            .map(
                              (u) => DropdownMenuItem<String>(
                                value: u.id,
                                child: Text(
                                  '${u.name} (${u.phone})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _parentId = v),
                        validator: (v) => v == null ? 'Select parent' : null,
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildStep2() {
    final ui = Responsive(context);

    final gap = ui.sh(ui.isMobile ? 14 : 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'Diagnosis * (select all that apply)'),

        SizedBox(height: ui.sh(8)),

        SelectableCardGroup(
          options: _diagnosisOpts,
          selected: _diagnoses,
          onTap: (v) {
            setState(() {
              _diagnoses.contains(v) ? _diagnoses.remove(v) : _diagnoses.add(v);
            });
          },
          validator: _diagnoses.isEmpty
              ? 'Please select at least one diagnosis'
              : null,
        ),

        SizedBox(height: gap),

        const FieldLabel(text: 'Severity Level *'),

        SizedBox(height: ui.sh(8)),

        Wrap(
          spacing: ui.sw(4),
          runSpacing: ui.sh(4),
          children: [
            SeverityCard(
              ui: ui,
              value: 'mild',
              title: 'Mild',
              color: AppColors.mintGreen,
              selectedValue: _severity,
              onChanged: (v) => setState(() => _severity = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'moderate',
              title: 'Moderate',
              color: AppColors.warmYellow,
              selectedValue: _severity,
              onChanged: (v) => setState(() => _severity = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'severe',
              title: 'Severe',
              color: AppColors.softCoral,
              selectedValue: _severity,
              onChanged: (v) => setState(() => _severity = v),
            ),
          ],
        ),

        SizedBox(height: gap),

        FieldLabel(text: 'Primary Concerns (select all that apply)'),

        SizedBox(height: ui.sh(8)),

        SelectableCardGroup(
          options: _concernOpts,
          selected: _concerns,
          onTap: (v) {
            setState(() {
              _concerns.contains(v) ? _concerns.remove(v) : _concerns.add(v);
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final ui = Responsive(context);

    final gap = ui.sh(ui.isMobile ? 14 : 18);

    Widget twoCol(Widget left, Widget right) {
      if (ui.isMobile) {
        return Column(
          children: [
            left,
            SizedBox(height: gap),
            right,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          SizedBox(width: gap),
          Expanded(child: right),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          text: 'Medical & Therapy History',
          icon: Icons.history_edu_outlined,
        ),

        SizedBox(height: gap),

        twoCol(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel(text: 'Birth History *'),

              SizedBox(height: ui.sh(10)),

              Wrap(
                spacing: ui.sw(8),
                runSpacing: ui.sh(8),
                children: [
                  SeverityCard(
                    ui: ui,
                    value: 'normal',
                    title: 'Normal',
                    color: AppColors.mintGreen,
                    selectedValue: _birthHistory,
                    onChanged: (v) {
                      setState(() {
                        _birthHistory = v;
                      });
                    },
                  ),

                  SeverityCard(
                    ui: ui,
                    value: 'premature',
                    title: 'Premature',
                    color: AppColors.warmYellow,
                    selectedValue: _birthHistory,
                    onChanged: (v) {
                      setState(() {
                        _birthHistory = v;
                      });
                    },
                  ),

                  SeverityCard(
                    ui: ui,
                    value: 'complications',
                    title: 'Complications',
                    color: AppColors.softCoral,
                    selectedValue: _birthHistory,
                    onChanged: (v) {
                      setState(() {
                        _birthHistory = v;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel(text: 'Development Flags'),

              SizedBox(height: ui.sh(10)),

              SelectableCardGroup(
                options: const [
                  'Milestones Delayed',
                  'Hearing Issues',
                  'Vision Issues',
                ],
                selected: {
                  if (_milestonesDelay) 'Milestones Delayed',
                  if (_hearingIssues) 'Hearing Issues',
                  if (_visionIssues) 'Vision Issues',
                },
                onTap: (value) {
                  setState(() {
                    switch (value) {
                      case 'Milestones Delayed':
                        _milestonesDelay = !_milestonesDelay;
                        break;

                      case 'Hearing Issues':
                        _hearingIssues = !_hearingIssues;
                        break;

                      case 'Vision Issues':
                        _visionIssues = !_visionIssues;
                        break;
                    }
                  });
                },
              ),
            ],
          ),
        ),

        SizedBox(height: gap),

        const FieldLabel(text: 'Current Medications'),

        SizedBox(height: ui.sh(10)),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _medCtr,
                style: TextStyle(fontSize: ui.ssp(14)),
                decoration: InputDecoration(
                  hintText: 'Enter medication name',
                  prefixIcon: Icon(
                    Icons.medication_outlined,
                    size: ui.sIcon(ui.isMobile ? 20 : 12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ui.sRadius(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ui.sRadius(12)),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ui.sRadius(12)),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: ui.sw(8)),

            FilledButton.icon(
              onPressed: () {
                final medicine = _medCtr.text.trim();

                if (medicine.isEmpty) return;

                setState(() {
                  if (!_medications.contains(medicine)) {
                    _medications.add(medicine);
                  }
                  _medCtr.clear();
                });
              },
              icon: Icon(Icons.add, size: ui.sIcon(ui.isMobile ? 18 : 14)),
              label: const Text("Add"),
            ),
          ],
        ),

        if (_medications.isNotEmpty) ...[
          SizedBox(height: ui.sh(12)),

          Wrap(
            spacing: ui.sw(8),
            runSpacing: ui.sh(8),
            children: _medications.map((medicine) {
              return Chip(
                avatar: const Icon(
                  Icons.medication,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                label: Text(medicine, style: TextStyle(fontSize: ui.ssp(13))),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _medications.remove(medicine);
                  });
                },
              );
            }).toList(),
          ),
        ],

        SizedBox(height: gap),

        const FieldLabel(text: 'Previous Therapy History *'),

        SizedBox(height: ui.sh(10)),

        SelectableCardGroup(
          options: const ['Yes', 'No'],
          selected: {_hadPrevTherapy ? 'Yes' : 'No'},
          onTap: (value) {
            setState(() {
              _hadPrevTherapy = value == 'Yes';
            });
          },
        ),

        if (_hadPrevTherapy) ...[
          SizedBox(height: gap),

          const FieldLabel(text: 'Previous Therapy Types'),

          SizedBox(height: ui.sh(10)),

          SelectableCardGroup(
            options: _prevTherapyOpts,
            selected: _prevTypes,
            onTap: (v) {
              setState(() {
                _prevTypes.contains(v)
                    ? _prevTypes.remove(v)
                    : _prevTypes.add(v);
              });
            },
          ),

          SizedBox(height: gap),

          ui.isMobile
              ? Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: ui.ssp(14)),
                      decoration: InputDecoration(
                        labelText: 'Duration (Months)',
                        prefixIcon: Icon(
                          Icons.schedule_outlined,
                          size: ui.sIcon(18),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ui.sRadius(12)),
                        ),
                      ),
                      onChanged: (v) => _prevMonths = int.tryParse(v) ?? 0,
                    ),

                    SizedBox(height: gap),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: ui.ssp(14)),
                        decoration: InputDecoration(
                          labelText: 'Duration (Months)',
                          prefixIcon: Icon(
                            Icons.schedule_outlined,
                            size: ui.sIcon(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ui.sRadius(12)),
                          ),
                        ),
                        onChanged: (v) => _prevMonths = int.tryParse(v) ?? 0,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),

          SizedBox(height: gap),
          TextFormField(
            controller: _progressCtr,
            style: TextStyle(fontSize: ui.ssp(14)),
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Progress Observed',
              hintText: 'Describe improvements from previous therapy',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: ui.sh(48)),
                child: Icon(
                  Icons.trending_up_outlined,
                  size: ui.sIcon(ui.isMobile ? 20 : 10),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ui.sRadius(12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ui.sRadius(12)),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ui.sRadius(12)),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep4() {
    final ui = Responsive(context);
    final gap = ui.sh(ui.isMobile ? 14 : 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          text: 'Functional Baseline',
          icon: Icons.insights_outlined,
        ),

        SizedBox(height: gap),
        HorizontalOptions(
          title: 'Communication',
          icon: Icons.record_voice_over_outlined,
          children: [
            SeverityCard(
              ui: ui,
              value: 'non_verbal',
              title: 'Non-Verbal',
              color: AppColors.softCoral,
              selectedValue: _commLevel,
              onChanged: (v) => setState(() => _commLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'single_words',
              title: 'Single Words',
              color: AppColors.warmYellow,
              selectedValue: _commLevel,
              onChanged: (v) => setState(() => _commLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'phrases',
              title: 'Phrases',
              color: AppColors.primaryBlue,
              selectedValue: _commLevel,
              onChanged: (v) => setState(() => _commLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'sentences',
              title: 'Sentences',
              color: AppColors.mintGreen,
              selectedValue: _commLevel,
              onChanged: (v) => setState(() => _commLevel = v),
            ),
          ],
        ),
        HorizontalOptions(
          title: 'Attention Span',
          icon: Icons.timer_outlined,
          children: [
            SizedBox(
              width: ui.isMobile ? double.infinity : 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_attentionMins.round()} minutes",
                    style: TextStyle(
                      fontSize: ui.ssp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Slider(
                    value: _attentionMins,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (v) {
                      setState(() {
                        _attentionMins = v;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        HorizontalOptions(
          title: 'Social Interaction',
          icon: Icons.groups_outlined,
          children: [
            SeverityCard(
              ui: ui,
              value: 'avoids',
              title: 'Avoids',
              color: AppColors.softCoral,
              selectedValue: _socialLevel,
              onChanged: (v) => setState(() => _socialLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'parallel',
              title: 'Parallel',
              color: AppColors.warmYellow,
              selectedValue: _socialLevel,
              onChanged: (v) => setState(() => _socialLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'interactive',
              title: 'Interactive',
              color: AppColors.mintGreen,
              selectedValue: _socialLevel,
              onChanged: (v) => setState(() => _socialLevel = v),
            ),
          ],
        ),
        HorizontalOptions(
          title: 'Motor Skills',
          icon: Icons.accessibility_new_outlined,
          children: [
            SeverityCard(
              ui: ui,
              value: 'low',
              title: 'Low',
              color: AppColors.softCoral,
              selectedValue: _motorLevel,
              onChanged: (v) => setState(() => _motorLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'medium',
              title: 'Medium',
              color: AppColors.warmYellow,
              selectedValue: _motorLevel,
              onChanged: (v) => setState(() => _motorLevel = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'age_appropriate',
              title: 'Age Appropriate',
              color: AppColors.mintGreen,
              selectedValue: _motorLevel,
              onChanged: (v) => setState(() => _motorLevel = v),
            ),
          ],
        ),
        HorizontalOptions(
          title: 'Behavior Pattern',
          icon: Icons.psychology_alt_outlined,
          children: [
            SeverityCard(
              ui: ui,
              value: 'calm',
              title: 'Calm',
              color: AppColors.mintGreen,
              selectedValue: _behaviorPat,
              onChanged: (v) => setState(() => _behaviorPat = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'mixed',
              title: 'Mixed',
              color: AppColors.warmYellow,
              selectedValue: _behaviorPat,
              onChanged: (v) => setState(() => _behaviorPat = v),
            ),

            SeverityCard(
              ui: ui,
              value: 'challenging',
              title: 'Challenging',
              color: AppColors.softCoral,
              selectedValue: _behaviorPat,
              onChanged: (v) => setState(() => _behaviorPat = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5() {
    final ui = Responsive(context);
    final gap = ui.sh(ui.isMobile ? 14 : 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          text: 'Sangat Layer - Home Context',
          icon: Icons.home_outlined,
        ),

        SizedBox(height: gap),

        DropdownButtonFormField<String>(
          initialValue: _caregiverCtr.text.isEmpty ? null : _caregiverCtr.text,
          decoration: InputDecoration(
            labelText: 'Primary Caregiver *',
            prefixIcon: Icon(
              Icons.family_restroom_outlined,
              size: ui.sIcon(ui.isMobile ? 18 : 10),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ui.sRadius(12)),
            ),
          ),
          hint: const Text('Select Caregiver'),
          items: const [
            DropdownMenuItem(value: 'mother', child: Text('Mother')),
            DropdownMenuItem(value: 'father', child: Text('Father')),
            DropdownMenuItem(value: 'grandparent', child: Text('Grandparent')),
            DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              _caregiverCtr.text = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a primary caregiver';
            }
            return null;
          },
        ),

        SizedBox(height: gap),

        HorizontalOptions(
          title: 'Daily Screen Time',
          icon: Icons.tv_outlined,
          children: [
            SizedBox(
              width: ui.isMobile ? double.infinity : 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_screenTime.toStringAsFixed(1)} hours/day",
                    style: TextStyle(
                      fontSize: ui.ssp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Slider(
                    value: _screenTime,
                    min: 0,
                    max: 12,
                    divisions: 24,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (v) {
                      setState(() {
                        _screenTime = v;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        HorizontalOptions(
          title: 'Play Type',
          icon: Icons.toys_outlined,
          children: [
            SeverityCard(
              ui: ui,
              value: 'alone',
              title: 'Alone',
              color: AppColors.softCoral,
              selectedValue: _playType,
              onChanged: (v) {
                setState(() {
                  _playType = v;
                });
              },
            ),

            SeverityCard(
              ui: ui,
              value: 'guided',
              title: 'Guided',
              color: AppColors.primaryBlue,
              selectedValue: _playType,
              onChanged: (v) {
                setState(() {
                  _playType = v;
                });
              },
            ),

            SeverityCard(
              ui: ui,
              value: 'group',
              title: 'Group',
              color: AppColors.mintGreen,
              selectedValue: _playType,
              onChanged: (v) {
                setState(() {
                  _playType = v;
                });
              },
            ),
          ],
        ),
        HorizontalOptions(
          title: 'Parent Involvement',
          icon: Icons.volunteer_activism_outlined,
          children: [
            SeverityCard(
              ui: ui,
              value: 'low',
              title: 'Low',
              color: AppColors.softCoral,
              selectedValue: _parentInv,
              onChanged: (v) {
                setState(() {
                  _parentInv = v;
                });
              },
            ),

            SeverityCard(
              ui: ui,
              value: 'medium',
              title: 'Medium',
              color: AppColors.warmYellow,
              selectedValue: _parentInv,
              onChanged: (v) {
                setState(() {
                  _parentInv = v;
                });
              },
            ),

            SeverityCard(
              ui: ui,
              value: 'high',
              title: 'High',
              color: AppColors.mintGreen,
              selectedValue: _parentInv,
              onChanged: (v) {
                setState(() {
                  _parentInv = v;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep6() {
    final ui = Responsive(context);
    final therapists = ref.watch(therapistsProvider);

    final gap = ui.sh(ui.isMobile ? 14 : 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          text: 'Goals, Targets & Consent',
          icon: Icons.flag_outlined,
        ),

        SizedBox(height: gap),

        const FieldLabel(text: 'Therapy Focus Areas *'),

        SizedBox(height: ui.sh(8)),

        SelectableCardGroup(
          options: _therapyTargetOpts,
          selected: _therapyTargets,
          validator: _therapyTargets.isEmpty
              ? 'Select at least one therapy focus area'
              : null,
          onTap: (v) {
            setState(() {
              if (_therapyTargets.contains(v)) {
                _therapyTargets.remove(v);
                _therapistAssignments.remove(v);
                _therapistSchedules.remove(v);
              } else {
                _therapyTargets.add(v);
              }
            });
          },
        ),

        SizedBox(height: gap),

        if (_therapyTargets.isNotEmpty) ...[
          const SectionTitle(
            text: 'Assign Therapists',
            icon: Icons.psychology_outlined,
          ),

          SizedBox(height: gap),

          therapists.when(
            loading: () => const LinearProgressIndicator(),

            error: (e, _) => Text(
              'Failed to load therapists: $e',
              style: TextStyle(
                color: AppColors.softCoral,
                fontSize: ui.ssp(13),
              ),
            ),

            data: (list) => Column(
              children: _therapyTargets.map((target) {
                final sched = _therapistSchedules[target];

                return Container(
                  margin: EdgeInsets.only(bottom: gap),
                  padding: EdgeInsets.all(ui.sw(8)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(ui.sRadius(6)),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ui.isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  target,
                                  style: TextStyle(
                                    fontSize: ui.ssp(14),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: ui.sh(10)),

                                TherapistDropdown(
                                  therapists: list,
                                  value: _therapistAssignments[target],
                                  onChanged: (value) {
                                    setState(() {
                                      _therapistAssignments[target] = value;

                                      _therapistSchedules.putIfAbsent(
                                        target,
                                        () => const ScheduleEntry(
                                          enrollmentMode: 'offline',
                                          days: [],
                                          fromTime: '09:00',
                                          toTime: '10:00',
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    target,
                                    style: TextStyle(
                                      fontSize: ui.ssp(14),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                SizedBox(width: gap),

                                Expanded(
                                  child: TherapistDropdown(
                                    therapists: list,
                                    value: _therapistAssignments[target],
                                    onChanged: (value) {
                                      setState(() {
                                        _therapistAssignments[target] = value;

                                        _therapistSchedules.putIfAbsent(
                                          target,
                                          () => const ScheduleEntry(
                                            enrollmentMode: 'offline',
                                            days: [],
                                            fromTime: '09:00',
                                            toTime: '10:00',
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                      if (_therapistAssignments[target] != null) ...[
                        SizedBox(height: gap),

                        SchedulePicker(
                          target: target,
                          schedule: sched,
                          required: _therapistAssignments[target] != null,
                          dayLabels: _dayLabels,
                          dayFullNames: _dayFullNames,
                          onChanged: (days, fromTime, toTime) {
                            final current = _therapistSchedules[target];

                            setState(() {
                              _therapistSchedules[target] = ScheduleEntry(
                                enrollmentMode:
                                    current?.enrollmentMode ?? 'offline',
                                days: days,
                                fromTime: fromTime ?? '09:00',
                                toTime: toTime ?? '10:00',
                              );
                            });
                          },
                        ),

                        SizedBox(height: gap),

                        DropdownButtonFormField<String>(
                          value: sched?.enrollmentMode ?? 'offline',
                          decoration: InputDecoration(
                            labelText: 'Enrollment Mode',
                            prefixIcon: Icon(
                              Icons.video_settings_outlined,
                              size: ui.sIcon(ui.isMobile ? 18 : 10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ui.sRadius(6),
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'offline',
                              child: Text('Offline'),
                            ),
                            DropdownMenuItem(
                              value: 'online',
                              child: Text('Online'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            final current = _therapistSchedules[target];
                            if (current == null) return;

                            setState(() {
                              _therapistSchedules[target] = ScheduleEntry(
                                enrollmentMode: value,
                                days: current.days,
                                fromTime: current.fromTime,
                                toTime: current.toTime,
                              );
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: gap),
        ],
        const FieldLabel(text: 'Top Priority Goals (Maximum 3)'),

        SizedBox(height: ui.sh(8)),

        SelectableCardGroup(
          options: _goalOpts,
          selected: _goalPriorities,
          validator: _goalPriorities.isEmpty
              ? 'Select at least one goal'
              : null,
          onTap: (v) {
            setState(() {
              if (_goalPriorities.contains(v)) {
                _goalPriorities.remove(v);
              } else if (_goalPriorities.length < 3) {
                _goalPriorities.add(v);
              }
            });
          },
        ),

        SizedBox(height: gap),

        HorizontalOptions(
          title: 'Expected Therapy Timeline',
          icon: Icons.schedule_outlined,
          children: [
            SizedBox(
              width: ui.isMobile ? double.infinity : 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_timeline.round()} months',
                    style: TextStyle(
                      fontSize: ui.ssp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Slider(
                    value: _timeline,
                    min: 1,
                    max: 24,
                    divisions: 23,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        _timeline = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        Divider(height: ui.sh(24)),

        // const SectionTitle(
        //   text: 'Consent Record',
        //   icon: Icons.verified_user_outlined,
        // ),
        SizedBox(height: gap),
        HorizontalOptions(
          title: 'Consent Information',
          icon: Icons.verified_user_outlined,
          children: [
            SizedBox(
              width: ui.isMobile ? double.infinity : 320,
              child: DropdownButtonFormField<String>(
                initialValue: _consentByCtr.text.isEmpty
                    ? null
                    : _consentByCtr.text,
                decoration: InputDecoration(
                  labelText: 'Consent Given By *',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    size: ui.sIcon(ui.isMobile ? 18 : 10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ui.sRadius(6)),
                  ),
                ),
                hint: const Text('Select'),
                items: const [
                  DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                  DropdownMenuItem(value: 'Father', child: Text('Father')),
                  DropdownMenuItem(value: 'Guardian', child: Text('Guardian')),
                  DropdownMenuItem(
                    value: 'Grandparent',
                    child: Text('Grandparent'),
                  ),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _consentByCtr.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select who gave consent';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        CheckboxListTile(
          value: _consentGiven,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primaryBlue,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'I confirm that informed consent has been obtained.',
            style: TextStyle(fontSize: ui.ssp(13), fontWeight: FontWeight.w500),
          ),
          onChanged: (value) {
            setState(() {
              _consentGiven = value ?? false;
            });
          },
        ),

        if (!_consentGiven)
          Padding(
            padding: EdgeInsets.only(left: ui.sw(12)),
            child: Text(
              'Consent is required before enrollment.',
              style: TextStyle(
                color: AppColors.softCoral,
                fontSize: ui.ssp(12),
              ),
            ),
          ),
      ],
    );
  }

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _dayFullNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

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
