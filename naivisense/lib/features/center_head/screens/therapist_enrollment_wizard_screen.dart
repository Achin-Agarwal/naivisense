import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/center_head/widgets/step1.dart';
import 'package:naivisense/features/center_head/widgets/step2_professional_qualifications.dart';
import 'package:naivisense/features/center_head/widgets/step3_specialization.dart';
import 'package:naivisense/features/center_head/widgets/step4_availability_documents.dart';
import 'package:naivisense/features/center_head/widgets/step_indicator.dart';
import 'package:naivisense/features/center_head/widgets/step_navigation_buttons.dart';
import '../../../core/theme/app_colors.dart';
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

  final _nameCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  DateTime? _dob;
  String _gender = 'male';

  final _qualCtr = TextEditingController();
  final _licenseCtr = TextEditingController();
  final _orgCtr = TextEditingController();
  final _certCtr = TextEditingController();
  int _yearsExp = 0;
  String _workplaceType = 'clinic';
  final _certifications = <String>[];

  final _therapyMethods = <String>{};
  final _conditionsHandled = <String>{};
  final _ageGroups = <String>{};

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(therapistEnrollmentProvider);
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,

        title: Text(
          'Enroll New Therapist',
          style: TextStyle(
            fontSize: r.sp(18, tablet: 20, desktop: 22),
            fontWeight: FontWeight.w600,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.close),
          iconSize: r.icon(24),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// Step Indicator
            StepIndicator(currentStep: _step, stepTitles: _stepTitles),

            /// Form
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: r.isDesktop
                        ? 850
                        : r.isTablet
                        ? 700
                        : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.horizontalPadding,
                      vertical: r.value(mobile: 16, tablet: 20, desktop: 24),
                    ),
                    child: Form(
                      key: _formKeys[_step],
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ),
            ),

            /// Error
            if (state.error != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.horizontalPadding,
                  vertical: r.h(6),
                ),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.softCoral,
                    fontSize: r.sp(12, tablet: 13),
                  ),
                ),
              ),

            /// Navigation Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: r.isDesktop
                      ? 850
                      : r.isTablet
                      ? 700
                      : double.infinity,
                ),
                child: StepNavigationButtons(
                  step: _step,
                  loading: state.loading,
                  onBack: _back,
                  onNext: _next,
                ),
              ),
            ),

            SizedBox(
              height: MediaQuery.paddingOf(context).bottom == 0
                  ? r.h(18)
                  : MediaQuery.paddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => TherapistStep1(
        nameController: _nameCtr,
        phoneController: _phoneCtr,
        emailController: _emailCtr,
        passwordController: _passwordCtr,
        obscurePassword: _obscurePassword,
        onPasswordToggle: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        dob: _dob,
        onDobChanged: (date) {
          setState(() {
            _dob = date;
          });
        },
        gender: _gender,
        genderOptions: _genderOpts,
        onGenderChanged: (value) {
          setState(() {
            _gender = value;
          });
        },
        ageYears: _ageYears,
      ),
      1 => Step2ProfessionalQualifications(
        qualificationController: _qualCtr,
        licenseController: _licenseCtr,
        organizationController: _orgCtr,
        certificationController: _certCtr,

        yearsExperience: _yearsExp,
        onYearsChanged: (value) => setState(() => _yearsExp = value.round()),

        workplaceOptions: _workplaceOpts,
        workplaceType: _workplaceType,
        onWorkplaceChanged: (value) => setState(() => _workplaceType = value),

        certifications: _certifications,

        onAddCertification: () {
          final value = _certCtr.text.trim();
          if (value.isNotEmpty) {
            setState(() {
              _certifications.add(value);
              _certCtr.clear();
            });
          }
        },

        onRemoveCertification: (value) {
          setState(() {
            _certifications.remove(value);
          });
        },
      ),
      2 => Step3Specialization(
        therapyMethodOptions: _therapyMethodOpts,
        therapyMethods: _therapyMethods,
        onTherapyMethodTap: (value) => setState(() {
          _therapyMethods.contains(value)
              ? _therapyMethods.remove(value)
              : _therapyMethods.add(value);
        }),

        conditionOptions: _conditionOpts,
        conditionsHandled: _conditionsHandled,
        onConditionTap: (value) => setState(() {
          _conditionsHandled.contains(value)
              ? _conditionsHandled.remove(value)
              : _conditionsHandled.add(value);
        }),

        ageGroupOptions: _ageGroupOpts,
        ageGroups: _ageGroups,
        onAgeGroupTap: (value) => setState(() {
          _ageGroups.contains(value)
              ? _ageGroups.remove(value)
              : _ageGroups.add(value);
        }),
      ),
      _ => Step4AvailabilityDocuments(
        dayOptions: _dayOpts,
        availableDays: _availableDays,
        onDayTap: (v) => setState(() {
          _availableDays.contains(v)
              ? _availableDays.remove(v)
              : _availableDays.add(v);
        }),

        modeOptions: _modeOpts,
        sessionModes: _sessionModes,
        onModeTap: (v) => setState(() {
          _sessionModes.contains(v)
              ? _sessionModes.remove(v)
              : _sessionModes.add(v);
        }),

        sessionDuration: _sessionDuration,
        onDurationChanged: (v) => setState(() => _sessionDuration = v),

        profileBytes: _profileBytes,
        degreeBytes: _degreeBytes,
        identityBytes: _identityBytes,

        onProfileTap: () => _pickImage('photo'),
        onDegreeTap: () => _pickImage('degree'),
        onIdentityTap: () => _pickImage('identity'),

        proofTypeOptions: _proofTypeOpts,
        identityProofType: _identityProofType,
        onProofTypeChanged: (v) => setState(() => _identityProofType = v),
      ),
    };
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
