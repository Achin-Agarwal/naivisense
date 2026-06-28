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
  final _nameCtr     = TextEditingController();
  final _phoneCtr    = TextEditingController();
  final _emailCtr    = TextEditingController();
  final _passwordCtr = TextEditingController();
  DateTime? _dob;
  String _gender = 'male';

  // ── Step 2: Qualifications ────────────────────────────────────────────────
  final _qualCtr   = TextEditingController();
  final _licenseCtr = TextEditingController();
  final _orgCtr    = TextEditingController();
  final _certCtr   = TextEditingController();
  int _yearsExp       = 0;
  String _workplaceType = 'clinic';
  final _certifications = <String>[];

  // ── Step 3: Specialization ────────────────────────────────────────────────
  final _therapyMethods    = <String>{};
  final _conditionsHandled = <String>{};
  final _ageGroups         = <String>{};

  // ── Step 4: Availability + Documents ─────────────────────────────────────
  final _availableDays = <String>{};
  final _sessionModes  = <String>{};
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
    'Speech Therapy', 'Occupational Therapy', 'ABA',
    'Special Education', 'Physical Therapy', 'Behavioral Therapy',
    'Social Skills Training', 'Sensory Integration', 'Play Therapy',
  ];
  static const _conditionOpts = [
    'ASD', 'ADHD', 'CP', 'Down Syndrome', 'Speech Delay',
    'Dyslexia', 'Sensory Processing', 'Global Delay', 'Learning Disability',
  ];
  static const _ageGroupOpts = ['0–3 years', '3–6 years', '6–12 years', '12+ years'];

  static const _dayOpts = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _modeOpts = ['In-person', 'Online', 'Home Visit'];
  static const _workplaceOpts = ['clinic', 'hospital', 'freelance', 'ngo'];
  static const _proofTypeOpts = ['aadhar', 'pan', 'passport', 'driving_license'];

  static const _stepTitles = [
    'Identity',
    'Qualifications',
    'Specialization',
    'Availability & Docs',
  ];

  @override
  void dispose() {
    _nameCtr.dispose(); _phoneCtr.dispose(); _emailCtr.dispose();
    _passwordCtr.dispose(); _qualCtr.dispose(); _licenseCtr.dispose();
    _orgCtr.dispose(); _certCtr.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _next() {
    if (!(_formKeys[_step].currentState?.validate() ?? true)) return;
    if (_step == 3) { _submit(); return; }
    setState(() => _step++);
  }

  void _back() { if (_step > 0) setState(() => _step--); }

  Future<void> _submit() async {
    final payload = {
      'name':              _nameCtr.text.trim(),
      'phone':             _phoneCtr.text.trim(),
      if (_emailCtr.text.isNotEmpty) 'email': _emailCtr.text.trim(),
      'password':          _passwordCtr.text,
      if (_dob != null) 'dob': _dob!.toUtc().toIso8601String(),
      'gender':            _gender,
      'qualification':     _qualCtr.text.trim(),
      if (_licenseCtr.text.isNotEmpty) 'license_number': _licenseCtr.text.trim(),
      'years_experience':  _yearsExp,
      'certifications':    _certifications,
      'workplace_type':    _workplaceType,
      if (_orgCtr.text.isNotEmpty) 'organization_name': _orgCtr.text.trim(),
      'conditions_handled': _conditionsHandled.toList(),
      'therapy_methods':   _therapyMethods.toList(),
      'age_groups':        _ageGroups.toList(),
      'available_days':    _availableDays.toList(),
      'session_modes':     _sessionModes.toList(),
      'session_duration':  _sessionDuration.round(),
      'identity_proof_type': _identityProofType,
    };

    final ok = await ref.read(therapistEnrollmentProvider.notifier).submit(
      data:          payload,
      profilePhoto:  _profilePhoto,
      degreeCert:    _degreeCert,
      identityProof: _identityProof,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _pickImage(String field) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      switch (field) {
        case 'photo':    _profilePhoto = file; _profileBytes = bytes;
        case 'degree':   _degreeCert   = file; _degreeBytes  = bytes;
        case 'identity': _identityProof = file; _identityBytes = bytes;
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(therapistEnrollmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enroll New Therapist'),
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

  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final done    = i < _step;
              final current = i == _step;
              return Expanded(
                child: Row(
                  children: [
                    _StepDot(index: i + 1, done: done, current: current),
                    if (i < 3)
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
            'Step ${_step + 1} of 4 — ${_stepTitles[_step]}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(bool loading) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: AppButton(label: 'Back', outlined: true, onPressed: _back),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: AppButton(
              label:     _step == 3 ? 'Enroll Therapist' : 'Next',
              loading:   loading,
              onPressed: _next,
              icon:      _step == 3 ? Icons.check : Icons.arrow_forward,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Basic Identity', Icons.person_outline),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameCtr,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneCtr,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number * (login credential)',
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: '+919876543200',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 10) return 'Enter a valid phone number';
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _emailCtr,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email (optional)',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passwordCtr,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Set Password *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1960),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );
            if (picked != null) setState(() => _dob = picked);
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
          const SizedBox(height: 6),
          Text('Age: ${_ageYears(_dob!)} years',
              style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
        ],
        const SizedBox(height: 20),
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
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Professional Qualifications
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Professional Qualifications', Icons.school_outlined),
        const SizedBox(height: 16),
        TextFormField(
          controller: _qualCtr,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Highest Degree / Qualification *',
            hintText: 'e.g. M.Sc. Speech-Language Pathology',
            prefixIcon: Icon(Icons.menu_book_outlined),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
          min: 0, max: 30, divisions: 30,
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
                  setState(() { _certifications.add(v); _certCtr.clear(); });
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
            spacing: 8, runSpacing: 4,
            children: _certifications.map((c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 12)),
              onDeleted: () => setState(() => _certifications.remove(c)),
              deleteIconColor: AppColors.textSecondary,
            )).toList(),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Specialization
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Specialization', Icons.psychology_outlined),
        const SizedBox(height: 4),
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
            _therapyMethods.contains(v) ? _therapyMethods.remove(v) : _therapyMethods.add(v);
          }),
          validator: _therapyMethods.isEmpty ? 'Select at least one method' : null,
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
            _ageGroups.contains(v) ? _ageGroups.remove(v) : _ageGroups.add(v);
          }),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 4 — Availability & Documents
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Availability', Icons.schedule_outlined),
        const SizedBox(height: 16),
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
          min: 15, max: 120, divisions: 21,
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
          label:    'Profile Photo',
          icon:     Icons.account_circle_outlined,
          bytes:    _profileBytes,
          onTap:    () => _pickImage('photo'),
        ),
        const SizedBox(height: 14),
        _label('Degree / Certificate'),
        const SizedBox(height: 8),
        _docUploadTile(
          label:  'Degree Certificate',
          icon:   Icons.workspace_premium_outlined,
          bytes:  _degreeBytes,
          onTap:  () => _pickImage('degree'),
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
            'aadhar'          => 'Aadhar',
            'pan'             => 'PAN Card',
            'passport'        => 'Passport',
            'driving_license' => 'Driving Licence',
            _ => v,
          },
        ),
        const SizedBox(height: 14),
        _docUploadTile(
          label:  'Identity Proof',
          icon:   Icons.credit_card_outlined,
          bytes:  _identityBytes,
          onTap:  () => _pickImage('identity'),
        ),
      ],
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────
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

  Widget _chipGroup({
    required List<String> options,
    required Set<String> selected,
    required void Function(String) onTap,
    bool single = false,
    String Function(String)? display,
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
            return GestureDetector(
              onTap: () => onTap(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withValues(alpha: 0.12)
                      : AppColors.background,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
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
              style: const TextStyle(color: AppColors.softCoral, fontSize: 12)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: bytes != null ? 120 : 70,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(
            color: bytes != null ? AppColors.primaryBlue : AppColors.divider,
            width: bytes != null ? 1.5 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: bytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(bytes, fit: BoxFit.cover),
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Tap to upload $label',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
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
  const _StepDot({required this.index, required this.done, required this.current});

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
