import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/therapist_enrollment_provider.dart';

class TherapistEnrollmentWizardScreen extends ConsumerStatefulWidget {
  const TherapistEnrollmentWizardScreen({super.key});

  @override
  ConsumerState<TherapistEnrollmentWizardScreen> createState() =>
      _TherapistEnrollmentWizardScreenState();
}

class _TherapistEnrollmentWizardScreenState
    extends ConsumerState<TherapistEnrollmentWizardScreen> {
  int _step = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  bool _obscurePassword = true;

  // ── Step 1: Identity ─────────────────────────────────────────────────────
  final _nameCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  DateTime? _dob;
  String _gender = 'male';

  // ── Step 2: Qualifications ────────────────────────────────────────────────
  final _qualCtr = TextEditingController();
  final _licenseCtr = TextEditingController();
  final _orgCtr = TextEditingController();
  final _certCtr = TextEditingController();
  int _yearsExp = 0;
  String _workplaceType = 'clinic';
  final _certifications = <String>[];

  // ── Step 3: Specialization ────────────────────────────────────────────────
  final _therapyMethods = <String>{};
  final _conditionsHandled = <String>{};
  final _ageGroups = <String>{};

  // ── Step 4: Availability + Documents ─────────────────────────────────────
  final _availableDays = <String>{};
  final _sessionModes = <String>{};
  double _sessionDuration = 45;
  String _identityProofType = 'aadhar';
  XFile? _profilePhoto;
  XFile? _degreeCert;
  XFile? _identityProof;
  // preview bytes
  Uint8List? _profileBytes;
  Uint8List? _degreeBytes;
  Uint8List? _identityBytes;

  // ── Options ───────────────────────────────────────────────────────────────
  static const _genderOpts = ['male', 'female', 'other'];

  static const _therapyMethodOpts = [
    'Speech Therapy',
    'Occupational Therapy',
    'ABA',
    'Special Education',
    'Physical Therapy',
    'Behavioral Therapy',
    'Social Skills Training',
    'Sensory Integration',
    'Play Therapy',
  ];
  static const _conditionOpts = [
    'ASD',
    'ADHD',
    'CP',
    'Down Syndrome',
    'Speech Delay',
    'Dyslexia',
    'Sensory Processing',
    'Global Delay',
    'Learning Disability',
  ];
  static const _ageGroupOpts = [
    '0–3 years',
    '3–6 years',
    '6–12 years',
    '12+ years',
  ];

  static const _dayOpts = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _modeOpts = ['In-person', 'Online', 'Home Visit'];
  static const _workplaceOpts = ['clinic', 'hospital', 'freelance', 'ngo'];
  static const _proofTypeOpts = [
    'aadhar',
    'pan',
    'passport',
    'driving_license',
  ];

  static const _stepTitles = [
    'Identity',
    'Qualifications',
    'Specialization',
    'Availability & Docs',
  ];

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    _emailCtr.dispose();
    _passwordCtr.dispose();
    _qualCtr.dispose();
    _licenseCtr.dispose();
    _orgCtr.dispose();
    _certCtr.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _next() {
    if (!(_formKeys[_step].currentState?.validate() ?? true)) return;
    if (_step == 3) {
      _submit();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    final payload = {
      'name': _nameCtr.text.trim(),
      'phone': _phoneCtr.text.trim(),
      if (_emailCtr.text.isNotEmpty) 'email': _emailCtr.text.trim(),
      'password': _passwordCtr.text,
      if (_dob != null) 'dob': _dob!.toUtc().toIso8601String(),
      'gender': _gender,
      'qualification': _qualCtr.text.trim(),
      if (_licenseCtr.text.isNotEmpty)
        'license_number': _licenseCtr.text.trim(),
      'years_experience': _yearsExp,
      'certifications': _certifications,
      'workplace_type': _workplaceType,
      if (_orgCtr.text.isNotEmpty) 'organization_name': _orgCtr.text.trim(),
      'conditions_handled': _conditionsHandled.toList(),
      'therapy_methods': _therapyMethods.toList(),
      'age_groups': _ageGroups.toList(),
      'available_days': _availableDays.toList(),
      'session_modes': _sessionModes.toList(),
      'session_duration': _sessionDuration.round(),
      'identity_proof_type': _identityProofType,
    };

    final ok = await ref
        .read(therapistEnrollmentProvider.notifier)
        .submit(
          data: payload,
          profilePhoto: _profilePhoto,
          degreeCert: _degreeCert,
          identityProof: _identityProof,
        );
    if (ok && mounted) Navigator.pop(context);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _pickImage(String field) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      switch (field) {
        case 'photo':
          _profilePhoto = file;
          _profileBytes = bytes;
        case 'degree':
          _degreeCert = file;
          _degreeBytes = bytes;
        case 'identity':
          _identityProof = file;
          _identityBytes = bytes;
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(therapistEnrollmentProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mq = MediaQuery.of(context);

        // Breakpoints
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        // Responsive values
        final horizontalPadding = isMobile
            ? 16.0
            : isTablet
            ? 28.0
            : 40.0;

        final verticalPadding = isMobile ? 16.0 : 24.0;

        final contentWidth = isDesktop
            ? 850.0
            : isTablet
            ? 700.0
            : double.infinity;

        final titleFont = isMobile
            ? 18.0
            : isTablet
            ? 20.0
            : 22.0;

        final errorFont = isMobile ? 12.0 : 13.0;

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,

            title: Text(
              'Enroll New Therapist',
              style: TextStyle(
                fontSize: titleFont,
                fontWeight: FontWeight.w600,
              ),
            ),

            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          body: SafeArea(
            child: Column(
              children: [
                // Step indicator
                _buildStepIndicator(),

                // Form
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Form(
                          key: _formKeys[_step],
                          child: _buildCurrentStep(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Error
                if (state.error != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 6,
                    ),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: AppColors.softCoral,
                        fontSize: errorFont,
                      ),
                    ),
                  ),

                // Bottom buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: _buildNavButtons(state.loading),
                  ),
                ),

                SizedBox(
                  height: mq.padding.bottom == 0 ? 18 : mq.padding.bottom,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Step Indicator ─────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
        ? 24.0
        : 40.0;

    final maxWidth = isMobile
        ? double.infinity
        : isTablet
        ? 700.0
        : 850.0;

    final textSize = isMobile
        ? 12.0
        : isTablet
        ? 13.0
        : 14.0;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 12 : 18,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(4, (i) {
                  final done = i < _step;
                  final current = i == _step;

                  return Expanded(
                    child: Row(
                      children: [
                        _StepDot(index: i + 1, done: done, current: current),
                        if (i < 3)
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 2,
                              color: done
                                  ? AppColors.primaryBlue
                                  : AppColors.divider,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),

              SizedBox(height: isMobile ? 8 : 12),

              Text(
                'Step ${_step + 1} of 4 — ${_stepTitles[_step]}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: textSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation Buttons ─────────────────────────────────────────────────────
  Widget _buildNavButtons(bool loading) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final verticalPadding = isMobile ? 18.0 : 22.0;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(top: 14, bottom: verticalPadding),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: SizedBox(
                height: isMobile ? 48 : 54,
                child: AppButton(
                  label: 'Back',
                  outlined: true,
                  onPressed: _back,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 18),
          ],

          Expanded(
            child: SizedBox(
              height: isMobile ? 48 : 54,
              child: AppButton(
                label: _step == 3 ? 'Enroll Therapist' : 'Next',
                loading: loading,
                onPressed: _next,
                icon: _step == 3 ? Icons.check : Icons.arrow_forward,
              ),
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
      _ => _buildStep4(),
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Identity
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep1() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;
        final isTablet = width >= 600 && width < 1024;

        Widget form = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Basic Identity', Icons.person_outline),
            SizedBox(height: isDesktop ? 24 : 16),

            TextFormField(
              controller: _nameCtr,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            SizedBox(height: isDesktop ? 20 : 14),

            TextFormField(
              controller: _phoneCtr,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: '+919876543210',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 10) return 'Enter valid phone';
                return null;
              },
            ),

            SizedBox(height: isDesktop ? 20 : 14),

            TextFormField(
              controller: _emailCtr,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            SizedBox(height: isDesktop ? 20 : 14),

            TextFormField(
              controller: _passwordCtr,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),

            SizedBox(height: isDesktop ? 24 : 20),

            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1960),
                  lastDate: DateTime.now().subtract(
                    const Duration(days: 365 * 18),
                  ),
                );

                if (picked != null) {
                  setState(() => _dob = picked);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    hintText: _dob == null
                        ? 'Tap to select'
                        : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                  ),
                ),
              ),
            ),

            if (_dob != null) ...[
              const SizedBox(height: 8),
              Text(
                'Age: ${_ageYears(_dob!)} years',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: isDesktop ? 14 : 13,
                ),
              ),
            ],

            SizedBox(height: isDesktop ? 24 : 20),

            _label('Gender'),

            const SizedBox(height: 8),

            _chipGroup(
              options: _genderOpts,
              selected: {_gender},
              single: true,
              onTap: (v) => setState(() => _gender = v),
              display: (v) => v[0].toUpperCase() + v.substring(1),
            ),
          ],
        );

        if (isDesktop) {
          return Center(child: SizedBox(width: 720, child: form));
        }

        if (isTablet) {
          return Center(child: SizedBox(width: 600, child: form));
        }

        return form;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Professional Qualifications
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;
        final isTablet = width >= 600 && width < 1024;

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Professional Qualifications', Icons.school_outlined),

            SizedBox(height: isDesktop ? 24 : 16),
            TextFormField(
              controller: _qualCtr,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Highest Degree / Qualification *',
                hintText: 'e.g. M.Sc. Speech-Language Pathology',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _licenseCtr,
              decoration: const InputDecoration(
                labelText: 'License / Registration No. (optional)',
                prefixIcon: Icon(Icons.verified_outlined),
              ),
            ),
            const SizedBox(height: 20),
            _label('Years of Experience: $_yearsExp'),
            Slider(
              value: _yearsExp.toDouble(),
              min: 0,
              max: 30,
              divisions: 30,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) => setState(() => _yearsExp = v.round()),
            ),
            const SizedBox(height: 12),
            _label('Workplace Type *'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _workplaceOpts,
              selected: {_workplaceType},
              single: true,
              onTap: (v) => setState(() => _workplaceType = v),
              display: (v) => v[0].toUpperCase() + v.substring(1),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _orgCtr,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Organization / Clinic Name (optional)',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 20),
            _label('Certifications (add one at a time)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _certCtr,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Certified ABA Therapist',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    final v = _certCtr.text.trim();
                    if (v.isNotEmpty) {
                      setState(() {
                        _certifications.add(v);
                        _certCtr.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_certifications.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _certifications
                    .map(
                      (c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        onDeleted: () =>
                            setState(() => _certifications.remove(c)),
                        deleteIconColor: AppColors.textSecondary,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        );
        if (isDesktop) {
          return Center(child: SizedBox(width: 760, child: content));
        }

        if (isTablet) {
          return Center(child: SizedBox(width: 620, child: content));
        }

        return content;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Specialization
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;
        final isTablet = width >= 600 && width < 1024;

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Specialization', Icons.psychology_outlined),

            SizedBox(height: isDesktop ? 24 : 16),
            const Text(
              'Define what this therapist treats and who they work with.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _label('Therapy Methods * (select all that apply)'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _therapyMethodOpts,
              selected: _therapyMethods,
              onTap: (v) => setState(() {
                _therapyMethods.contains(v)
                    ? _therapyMethods.remove(v)
                    : _therapyMethods.add(v);
              }),
              validator: _therapyMethods.isEmpty
                  ? 'Select at least one method'
                  : null,
            ),
            const SizedBox(height: 20),
            _label('Conditions Handled (select all that apply)'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _conditionOpts,
              selected: _conditionsHandled,
              onTap: (v) => setState(() {
                _conditionsHandled.contains(v)
                    ? _conditionsHandled.remove(v)
                    : _conditionsHandled.add(v);
              }),
            ),
            const SizedBox(height: 20),
            _label('Age Groups Served'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _ageGroupOpts,
              selected: _ageGroups,
              onTap: (v) => setState(() {
                _ageGroups.contains(v)
                    ? _ageGroups.remove(v)
                    : _ageGroups.add(v);
              }),
            ),
          ],
        );
        if (isDesktop) {
          return Center(child: SizedBox(width: 760, child: content));
        }

        if (isTablet) {
          return Center(child: SizedBox(width: 620, child: content));
        }

        return content;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 4 — Availability & Documents
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep4() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;
        final isTablet = width >= 600 && width < 1024;

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Availability', Icons.schedule_outlined),

            SizedBox(height: isDesktop ? 24 : 16),
            _label('Available Days'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _dayOpts,
              selected: _availableDays,
              onTap: (v) => setState(() {
                _availableDays.contains(v)
                    ? _availableDays.remove(v)
                    : _availableDays.add(v);
              }),
            ),
            const SizedBox(height: 20),
            _label('Session Modes'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _modeOpts,
              selected: _sessionModes,
              onTap: (v) => setState(() {
                _sessionModes.contains(v)
                    ? _sessionModes.remove(v)
                    : _sessionModes.add(v);
              }),
            ),
            const SizedBox(height: 20),
            _label('Session Duration: ${_sessionDuration.round()} minutes'),
            Slider(
              value: _sessionDuration,
              min: 15,
              max: 120,
              divisions: 21,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) => setState(() => _sessionDuration = v),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _sectionTitle('Documents', Icons.folder_copy_outlined),
            const SizedBox(height: 4),
            const Text(
              'All documents are optional. Photos are stored securely.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _label('Profile Photo'),
            const SizedBox(height: 8),
            _docUploadTile(
              label: 'Profile Photo',
              icon: Icons.account_circle_outlined,
              bytes: _profileBytes,
              onTap: () => _pickImage('photo'),
            ),
            const SizedBox(height: 14),
            _label('Degree / Certificate'),
            const SizedBox(height: 8),
            _docUploadTile(
              label: 'Degree Certificate',
              icon: Icons.workspace_premium_outlined,
              bytes: _degreeBytes,
              onTap: () => _pickImage('degree'),
            ),
            const SizedBox(height: 20),
            _label('Identity Proof Type'),
            const SizedBox(height: 8),
            _chipGroup(
              options: _proofTypeOpts,
              selected: {_identityProofType},
              single: true,
              onTap: (v) => setState(() => _identityProofType = v),
              display: (v) => switch (v) {
                'aadhar' => 'Aadhar',
                'pan' => 'PAN Card',
                'passport' => 'Passport',
                'driving_license' => 'Driving Licence',
                _ => v,
              },
            ),
            const SizedBox(height: 14),
            _docUploadTile(
              label: 'Identity Proof',
              icon: Icons.credit_card_outlined,
              bytes: _identityBytes,
              onTap: () => _pickImage('identity'),
            ),
          ],
        );
        if (isDesktop) {
          return Center(child: SizedBox(width: 760, child: content));
        }

        if (isTablet) {
          return Center(child: SizedBox(width: 620, child: content));
        }

        return content;
      },
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────
  Widget _sectionTitle(String text, IconData icon) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: isDesktop
              ? 28
              : isTablet
              ? 25
              : 22,
        ),
        SizedBox(width: isDesktop ? 12 : 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isDesktop
                  ? 22
                  : isTablet
                  ? 19
                  : 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    return Text(
      text,
      style: TextStyle(
        fontSize: isDesktop
            ? 15
            : isTablet
            ? 14
            : 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _chipGroup({
    required List<String> options,
    required Set<String> selected,
    required void Function(String) onTap,
    bool single = false,
    String Function(String)? display,
    String? validator,
  }) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: isDesktop ? 12 : 8,
          runSpacing: isDesktop ? 12 : 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            final label = display != null ? display(opt) : opt;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onTap(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? 18
                        : isTablet
                        ? 16
                        : 14,
                    vertical: isDesktop ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: .12)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isDesktop
                          ? 14
                          : isTablet
                          ? 13.5
                          : 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (validator != null) ...[
          const SizedBox(height: 6),
          Text(
            validator,
            style: const TextStyle(color: AppColors.softCoral, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _docUploadTile({
    required String label,
    required IconData icon,
    required Uint8List? bytes,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    final tileHeight = bytes != null
        ? (isDesktop ? 170 : 140)
        : (isDesktop ? 90 : 70);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: tileHeight.toDouble(),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bytes != null ? AppColors.primaryBlue : AppColors.divider,
              width: bytes != null ? 1.5 : 1,
            ),
          ),
          child: bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(bytes, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: isDesktop ? 28 : 22,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: isDesktop ? 14 : 10),
                      Text(
                        'Tap to upload $label',
                        style: TextStyle(
                          fontSize: isDesktop ? 15 : 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
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
}

// ── Step dot widget ───────────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  final int index;
  final bool done;
  final bool current;

  const _StepDot({
    required this.index,
    required this.done,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    final size = isDesktop
        ? 36.0
        : isTablet
        ? 32.0
        : 28.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
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
            ? Icon(Icons.check, color: Colors.white, size: isDesktop ? 18 : 14)
            : Text(
                "$index",
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 12,
                  fontWeight: FontWeight.w600,
                  color: current ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
