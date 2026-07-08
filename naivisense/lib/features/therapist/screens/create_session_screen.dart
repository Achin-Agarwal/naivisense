import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/child_dropdown.dart';
import 'package:naivisense/features/therapist/widgets/date_time_selector.dart';
import 'package:naivisense/features/therapist/widgets/duration_selector.dart';
import 'package:naivisense/features/therapist/widgets/session_mode_selector.dart';
import 'package:naivisense/features/therapist/widgets/session_title.dart';
import 'package:naivisense/features/therapist/widgets/session_type_selector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/therapist_provider.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  final ChildModel? preselectedChild;
  const CreateSessionScreen({super.key, this.preselectedChild});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _childId;
  String _type = 'speech';
  String _mode = 'offline';
  int _durationMin = 45;
  final DateTime initial = DateTime.now().add(const Duration(hours: 1));

  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();

    _childId = widget.preselectedChild?.id;

    _date = initial;
    _time = TimeOfDay.fromDateTime(initial);
  }

  static const _sessionTypes = [
    {
      'key': 'speech',
      'label': 'Speech Therapy',
      'icon': Icons.record_voice_over_outlined,
    },
    {
      'key': 'ot',
      'label': 'Occupational Therapy',
      'icon': Icons.handshake_outlined,
    },
    {
      'key': 'behavior',
      'label': 'Behavioral Therapy',
      'icon': Icons.psychology_outlined,
    },
    {
      'key': 'special_ed',
      'label': 'Special Education',
      'icon': Icons.school_outlined,
    },
  ];

  static const _durations = [15, 30, 45, 60, 90];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  DateTime get _scheduledAt {
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'child_id': _childId,
      'type': _type,
      'mode': _mode,
      'duration_min': _durationMin,
      'scheduled_at': _scheduledAt.toUtc().toIso8601String(),
    };
    if (_scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time.')),
      );
      return;
    }

    final ok = await ref.read(createSessionProvider.notifier).submit(payload);
    if (ok && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSessionProvider);
    final children = ref.watch(therapistChildrenProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = Responsive(context);

        final horizontalPadding = responsive.horizontalPadding;

        Widget body = Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(horizontalPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: responsive.formWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            title: 'Select Child',
                            icon: Icons.child_care_outlined,
                          ),

                          responsive.gapH(12, tablet: 14, desktop: 16),

                          ChildDropdown(
                            children: children,
                            selectedChildId: _childId,
                            onChanged: (value) {
                              setState(() => _childId = value);
                            },
                          ),

                          responsive.gapH(24, tablet: 28, desktop: 32),

                          SectionTitle(
                            title: 'Session Type',
                            icon: Icons.category_outlined,
                          ),

                          responsive.gapH(12, tablet: 14, desktop: 16),

                          SessionTypeSelector(
                            sessionTypes: _sessionTypes,
                            selectedType: _type,
                            onSelected: (value) {
                              setState(() => _type = value);
                            },
                          ),

                          responsive.gapH(24, tablet: 28, desktop: 32),

                          SectionTitle(
                            title: 'Date & Time',
                            icon: Icons.schedule_outlined,
                          ),

                          responsive.gapH(12, tablet: 14, desktop: 16),

                          DateTimeSelector(
                            date: _date,
                            time: _time,
                            onDateTap: _pickDate,
                            onTimeTap: _pickTime,
                          ),

                          responsive.gapH(24, tablet: 28, desktop: 32),

                          SectionTitle(
                            title: 'Duration',
                            icon: Icons.timelapse_outlined,
                          ),

                          responsive.gapH(12, tablet: 14, desktop: 16),

                          DurationSelector(
                            durations: _durations,
                            selectedDuration: _durationMin,
                            onSelected: (duration) {
                              setState(() => _durationMin = duration);
                            },
                          ),

                          responsive.gapH(24, tablet: 28, desktop: 32),

                          SectionTitle(
                            title: 'Session Mode',
                            icon: Icons.videocam_outlined,
                          ),

                          responsive.gapH(12, tablet: 14, desktop: 16),

                          SessionModeSelector(
                            selectedMode: _mode,
                            onSelected: (value) {
                              setState(() => _mode = value);
                            },
                          ),

                          responsive.gapH(16, tablet: 20, desktop: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (state.error != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 4,
                ),
                child: Text(
                  state.error!,
                  style: TextStyle(
                    color: AppColors.softCoral,
                    fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                  ),
                ),
              ),

            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsive.formWidth),
                  child: AppButton(
                    label: 'Schedule Session',
                    loading: state.loading,
                    onPressed: _submit,
                    icon: Icons.event_available_outlined,
                  ),
                ),
              ),
            ),
          ],
        );

        // Center on tablet and desktop
        if (responsive.isTablet || responsive.isDesktop) {
          body = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.formWidth),
              child: body,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,

          appBar: AppBar(
            title: Text(
              'Schedule Session',
              style: TextStyle(
                fontSize: responsive.sp(18, tablet: 20, desktop: 22),
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),

          body: SafeArea(child: body),
        );
      },
    );
  }
}
