import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/mood_selector.dart';
import 'package:naivisense/features/therapist/widgets/session_activities_selector.dart';
import 'package:naivisense/features/therapist/widgets/session_notes_header.dart';
import 'package:naivisense/features/therapist/widgets/session_observations_section.dart';
import 'package:naivisense/features/therapist/widgets/session_title.dart';
import 'package:naivisense/features/therapist/widgets/skill_scores_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/therapist_provider.dart';

class SessionNotesScreen extends ConsumerStatefulWidget {
  final SessionModel session;
  final String childName;
  final SessionNotes? existingNotes;

  const SessionNotesScreen({
    super.key,
    required this.session,
    required this.childName,
    this.existingNotes,
  });
  bool get isEditing => existingNotes != null;

  @override
  ConsumerState<SessionNotesScreen> createState() => _SessionNotesScreenState();
}

class _SessionNotesScreenState extends ConsumerState<SessionNotesScreen> {
  String _mood = 'calm';
  int _attentionScore = 5;
  int _communicationScore = 5;
  int _motorScore = 5;
  int _behaviorScore = 5;
  var _activities = <String>{};
  final _whatWorkedCtr = TextEditingController();
  final _whatDidntCtr = TextEditingController();
  final _homeworkCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    final notes = widget.existingNotes;

    if (notes != null) {
      _mood = notes.mood;

      _attentionScore = notes.attentionScore;
      _communicationScore = notes.communicationScore;
      _motorScore = notes.motorScore;
      _behaviorScore = notes.behaviorScore;

      _activities = notes.activities.toSet();

      _whatWorkedCtr.text = notes.whatWorked ?? '';
      _whatDidntCtr.text = notes.whatDidntWork ?? '';
      _homeworkCtr.text = notes.homework ?? '';
    }
  }

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

    if (widget.isEditing) {
      await ref
          .read(sessionNotesProvider.notifier)
          .update(widget.session.id, payload);
    } else {
      await ref
          .read(sessionNotesProvider.notifier)
          .submit(widget.session.id, payload);
    }

    if (mounted && ref.read(sessionNotesProvider).success) {
      Navigator.pop(context, true);
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
            title: Text(
              widget.isEditing ? "Edit Session Notes" : "Session Notes",
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: Column(
            children: [
              SessionNotesHeader(
                childName: widget.childName,
                session: widget.session,
              ),

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
                        SectionTitle(
                          title: "Child's Mood Today",
                          icon: Icons.emoji_emotions_outlined,
                        ),

                        r.gapH(16),

                        MoodSelector(
                          selectedMood: _mood,
                          moodData: _moodData,
                          onChanged: (value) {
                            setState(() {
                              _mood = value;
                            });
                          },
                        ),

                        r.gapH(28),

                        SkillScoresSection(
                          attentionScore: _attentionScore,
                          communicationScore: _communicationScore,
                          motorScore: _motorScore,
                          behaviorScore: _behaviorScore,
                          onAttentionChanged: (v) =>
                              setState(() => _attentionScore = v),
                          onCommunicationChanged: (v) =>
                              setState(() => _communicationScore = v),
                          onMotorChanged: (v) =>
                              setState(() => _motorScore = v),
                          onBehaviorChanged: (v) =>
                              setState(() => _behaviorScore = v),
                        ),

                        r.gapH(28),

                        SessionActivitiesSelector(
                          activities: _activityOptions,
                          selectedActivities: _activities,
                          onChanged: (activities) {
                            setState(() {
                              _activities = activities;
                            });
                          },
                        ),

                        r.gapH(28),

                        SessionObservationsSection(
                          whatWorkedController: _whatWorkedCtr,
                          whatDidntController: _whatDidntCtr,
                          homeworkController: _homeworkCtr,
                        ),

                        r.gapH(28),
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
                  width: r.isDesktop ? 300 : double.infinity,
                  child: AppButton(
                    label: widget.isEditing ? "Update Notes" : "Save Notes",
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
}
