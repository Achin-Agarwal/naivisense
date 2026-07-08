import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/rating_slider.dart';
import '../providers/therapist_provider.dart';

class SessionNotesScreen extends ConsumerStatefulWidget {
  final SessionModel session;
  final String childName;

  const SessionNotesScreen({
    super.key,
    required this.session,
    required this.childName,
  });

  @override
  ConsumerState<SessionNotesScreen> createState() => _SessionNotesScreenState();
}

class _SessionNotesScreenState extends ConsumerState<SessionNotesScreen> {
  String _mood = 'calm';
  int _attentionScore = 5;
  int _communicationScore = 5;
  int _motorScore = 5;
  int _behaviorScore = 5;
  final _activities = <String>{};
  final _whatWorkedCtr = TextEditingController();
  final _whatDidntCtr = TextEditingController();
  final _homeworkCtr = TextEditingController();

  static const _moodData = [
    {'key': 'sad', 'emoji': '😢', 'label': 'Sad', 'color': Color(0xFF5B8DEF)},
    {'key': 'calm', 'emoji': '😐', 'label': 'Calm', 'color': Color(0xFF4CD7A2)},
    {
      'key': 'happy',
      'emoji': '🙂',
      'label': 'Happy',
      'color': Color(0xFFFFD56B),
    },
    {
      'key': 'excited',
      'emoji': '😄',
      'label': 'Excited',
      'color': Color(0xFFFF9F43),
    },
  ];

  static const _activityOptions = [
    'Ball Play',
    'Sound Imitation',
    'Mirror Imitation',
    'Object Matching',
    'Puzzle Activity',
    'Pretend Play',
    'Drawing / Art',
    'Gross Motor',
    'Fine Motor',
    'Sorting / Stacking',
    'Music / Rhythm',
    'Social Story',
    'Turn Taking',
    'Flash Cards',
    'Sensory Play',
    'Breathing Exercise',
    'Role Play',
    'AAC Device',
  ];

  @override
  void dispose() {
    _whatWorkedCtr.dispose();
    _whatDidntCtr.dispose();
    _homeworkCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final payload = {
      'mood': _mood,
      'attention_score': _attentionScore,
      'communication_score': _communicationScore,
      'motor_score': _motorScore,
      'behavior_score': _behaviorScore,
      'activities': _activities.toList(),
      if (_whatWorkedCtr.text.trim().isNotEmpty)
        'what_worked': _whatWorkedCtr.text.trim(),
      if (_whatDidntCtr.text.trim().isNotEmpty)
        'what_didnt_work': _whatDidntCtr.text.trim(),
      if (_homeworkCtr.text.trim().isNotEmpty)
        'homework': _homeworkCtr.text.trim(),
    };

    await ref
        .read(sessionNotesProvider.notifier)
        .submit(widget.session.id, payload);

    if (mounted && ref.read(sessionNotesProvider).success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session notes saved — AI snapshot rebuilding'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionNotesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final r = Responsive(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Session Notes', style: TextStyle(fontSize: r.sp(18))),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildHeader(r),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(r.w(20)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: r.isDesktop ? 900 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMoodSection(r),

                        SizedBox(height: r.h(28)),

                        _buildSkillScores(r),

                        SizedBox(height: r.h(28)),

                        _buildActivities(r),

                        SizedBox(height: r.h(28)),

                        _buildObservations(r),

                        SizedBox(height: r.h(20)),
                      ],
                    ),
                  ),
                ),
              ),

              if (state.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(20),
                    vertical: r.h(4),
                  ),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: AppColors.softCoral,
                      fontSize: r.sp(13),
                    ),
                  ),
                ),

              Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(
                  r.w(20),
                  r.h(12),
                  r.w(20),
                  r.h(28),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Save Notes',
                    loading: state.loading,
                    onPressed: _submit,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header card ───────────────────────────────────────────────────────────
  Widget _buildHeader(Responsive r) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(r.w(20), 0, r.w(20), r.h(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: r.w(22),
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: Text(
              widget.childName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(18),
              ),
            ),
          ),

          SizedBox(width: r.w(12)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.childName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(16),
                  ),
                ),

                SizedBox(height: r.h(2)),

                Text(
                  '${widget.session.typeLabel} • ${AppDateUtils.formatTime(widget.session.scheduledAt)} • ${widget.session.durationMin} min',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: r.sp(12),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: r.w(8)),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.w(10),
              vertical: r.h(4),
            ),
            decoration: BoxDecoration(
              color: AppColors.mintGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(r.w(20)),
            ),
            child: Text(
              widget.session.mode == 'online' ? 'Online' : 'In-Person',
              style: TextStyle(
                color: AppColors.mintGreen,
                fontSize: r.sp(12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection(Responsive r) {
    final crossAxisCount = r.isMobile ? 2 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(r, "Child's Mood Today", Icons.emoji_emotions_outlined),

        SizedBox(height: r.h(16)),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _moodData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: r.w(10),
            mainAxisSpacing: r.h(10),
            childAspectRatio: r.isMobile ? 1.15 : 0.95,
          ),
          itemBuilder: (context, index) {
            final mood = _moodData[index];

            final key = mood['key'] as String;
            final emoji = mood['emoji'] as String;
            final label = mood['label'] as String;
            final color = mood['color'] as Color;

            final selected = _mood == key;

            return GestureDetector(
              onTap: () => setState(() => _mood = key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(8),
                  vertical: r.h(14),
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.surface,
                  border: Border.all(
                    color: selected ? color : AppColors.divider,
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(r.w(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(
                        fontSize: selected ? r.sp(34) : r.sp(28),
                      ),
                    ),

                    SizedBox(height: r.h(8)),

                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.sp(12),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected ? color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkillScores(Responsive r) {
    final sliders = [
      RatingSlider(
        label: 'Attention & Focus',
        value: _attentionScore,
        onChanged: (v) => setState(() => _attentionScore = v),
      ),
      RatingSlider(
        label: 'Communication',
        value: _communicationScore,
        onChanged: (v) => setState(() => _communicationScore = v),
      ),
      RatingSlider(
        label: 'Motor Skills',
        value: _motorScore,
        onChanged: (v) => setState(() => _motorScore = v),
      ),
      RatingSlider(
        label: 'Social Behavior',
        value: _behaviorScore,
        onChanged: (v) => setState(() => _behaviorScore = v),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(r, 'Skill Scores', Icons.bar_chart_outlined),

        SizedBox(height: r.h(16)),

        if (r.isMobile) ...[
          sliders[0],
          SizedBox(height: r.h(14)),
          sliders[1],
          SizedBox(height: r.h(14)),
          sliders[2],
          SizedBox(height: r.h(14)),
          sliders[3],
        ] else
          Wrap(
            spacing: r.w(20),
            runSpacing: r.h(20),
            children: sliders.map((slider) {
              return SizedBox(
                width: r.isDesktop
                    ? 380
                    : (MediaQuery.of(context).size.width - r.w(80)) / 2,
                child: slider,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActivities(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(r, 'Activities Used', Icons.sports_handball_outlined),

        SizedBox(height: r.h(6)),

        Text(
          'Select all activities done in this session',
          style: TextStyle(color: AppColors.textSecondary, fontSize: r.sp(12)),
        ),

        SizedBox(height: r.h(16)),

        Wrap(
          spacing: r.w(10),
          runSpacing: r.h(10),
          children: _activityOptions.map((activity) {
            final selected = _activities.contains(activity);

            return InkWell(
              borderRadius: BorderRadius.circular(r.w(24)),
              onTap: () {
                setState(() {
                  if (selected) {
                    _activities.remove(activity);
                  } else {
                    _activities.add(activity);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(14),
                  vertical: r.h(10),
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue.withValues(alpha: 0.10)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(r.w(24)),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.divider,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  activity,
                  style: TextStyle(
                    fontSize: r.sp(13),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _observationField(
    Responsive r, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildObservations(Responsive r) {
    final fields = [
      _observationField(
        r,
        controller: _whatWorkedCtr,
        label: 'What Worked Today',
        hint: 'Activities or approaches that led to positive responses...',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.mintGreen,
      ),
      _observationField(
        r,
        controller: _whatDidntCtr,
        label: "What Didn't Work",
        hint: 'What caused disengagement, refusal, or meltdowns...',
        icon: Icons.cancel_outlined,
        iconColor: AppColors.softCoral,
      ),
      _observationField(
        r,
        controller: _homeworkCtr,
        label: 'Homework Assigned',
        hint: 'Activities to practice at home before next session...',
        icon: Icons.home_outlined,
        iconColor: AppColors.warmYellow,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(r, 'Session Observations', Icons.notes_outlined),

        SizedBox(height: r.h(16)),

        if (r.isMobile) ...[
          fields[0],
          SizedBox(height: r.h(16)),
          fields[1],
          SizedBox(height: r.h(16)),
          fields[2],
        ] else
          Wrap(
            spacing: r.w(20),
            runSpacing: r.h(20),
            children: fields
                .map(
                  (field) => SizedBox(
                    width: r.isDesktop
                        ? 400
                        : (MediaQuery.of(context).size.width - r.w(90)) / 2,
                    child: field,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _sectionTitle(Responsive r, String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: r.icon(20, tablet: 22, desktop: 24),
        ),
        SizedBox(width: r.w(8, tablet: 10, desktop: 12)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: r.sp(16, tablet: 18, desktop: 20),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
