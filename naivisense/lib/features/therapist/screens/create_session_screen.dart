import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
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
  String _type        = 'speech';
  String _mode        = 'offline';
  int _durationMin    = 45;
  DateTime _date      = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _time     = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _childId = widget.preselectedChild?.id;
  }

  static const _sessionTypes = [
    {'key': 'speech',      'label': 'Speech Therapy',        'icon': Icons.record_voice_over_outlined},
    {'key': 'ot',          'label': 'Occupational Therapy',  'icon': Icons.handshake_outlined},
    {'key': 'behavior',    'label': 'Behavioral Therapy',    'icon': Icons.psychology_outlined},
    {'key': 'special_ed',  'label': 'Special Education',     'icon': Icons.school_outlined},
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
      _date.year, _date.month, _date.day,
      _time.hour, _time.minute,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'child_id':     _childId,
      'type':         _type,
      'mode':         _mode,
      'duration_min': _durationMin,
      'scheduled_at': _scheduledAt.toUtc().toIso8601String(),
    };

    final ok = await ref.read(createSessionProvider.notifier).submit(payload);
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session scheduled successfully'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(createSessionProvider);
    final children = ref.watch(therapistChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Schedule Session'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Child ──────────────────────────────────────────────
                    _sectionTitle('Select Child', Icons.child_care_outlined),
                    const SizedBox(height: 12),
                    children.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Failed to load: $e',
                          style: const TextStyle(color: AppColors.softCoral)),
                      data: (list) => DropdownButtonFormField<String>(
                        initialValue: _childId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Select child',
                        ),
                        items: list.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.name}  (${c.ageYears} yrs)'),
                        )).toList(),
                        onChanged: (v) => setState(() => _childId = v),
                        validator: (v) => v == null ? 'Select a child' : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Session type ───────────────────────────────────────
                    _sectionTitle('Session Type', Icons.category_outlined),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.6,
                      children: _sessionTypes.map((t) {
                        final key   = t['key'] as String;
                        final label = t['label'] as String;
                        final icon  = t['icon'] as IconData;
                        final sel   = _type == key;
                        return GestureDetector(
                          onTap: () => setState(() => _type = key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                  : AppColors.surface,
                              border: Border.all(
                                color: sel
                                    ? AppColors.primaryBlue
                                    : AppColors.divider,
                                width: sel ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon,
                                    size: 16,
                                    color: sel
                                        ? AppColors.primaryBlue
                                        : AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: sel
                                          ? AppColors.primaryBlue
                                          : AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Date & Time ────────────────────────────────────────
                    _sectionTitle('Date & Time', Icons.schedule_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _tappableField(
                            label: AppDateUtils.formatDate(_date),
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _tappableField(
                            label: _time.format(context),
                            icon: Icons.access_time_outlined,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Duration ───────────────────────────────────────────
                    _sectionTitle('Duration', Icons.timelapse_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: _durations.map((d) {
                        final sel = _durationMin == d;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _durationMin = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                    : AppColors.surface,
                                border: Border.all(
                                  color: sel
                                      ? AppColors.primaryBlue
                                      : AppColors.divider,
                                  width: sel ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$d m',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: sel
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Mode ───────────────────────────────────────────────
                    _sectionTitle('Session Mode', Icons.videocam_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: ['offline', 'online'].map((m) {
                        final sel   = _mode == m;
                        final label = m == 'offline' ? 'In-Person' : 'Online';
                        final icon  = m == 'offline'
                            ? Icons.people_outlined
                            : Icons.video_call_outlined;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mode = m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: EdgeInsets.only(
                                  right: m == 'offline' ? 6 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                    : AppColors.surface,
                                border: Border.all(
                                  color: sel
                                      ? AppColors.primaryBlue
                                      : AppColors.divider,
                                  width: sel ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(icon,
                                      color: sel
                                          ? AppColors.primaryBlue
                                          : AppColors.textSecondary),
                                  const SizedBox(height: 4),
                                  Text(label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: sel
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: sel
                                            ? AppColors.primaryBlue
                                            : AppColors.textSecondary,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(state.error!,
                  style: const TextStyle(
                      color: AppColors.softCoral, fontSize: 13)),
            ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: AppButton(
              label:     'Schedule Session',
              loading:   state.loading,
              onPressed: _submit,
              icon:      Icons.event_available_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _tappableField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
