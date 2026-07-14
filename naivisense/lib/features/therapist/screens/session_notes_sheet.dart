import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/rating_slider.dart';
import '../providers/therapist_provider.dart';

void showSessionNotesSheet(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SessionNotesSheet(sessionId: sessionId),
  );
}

class _SessionNotesSheet extends ConsumerStatefulWidget {
  final String sessionId;
  const _SessionNotesSheet({required this.sessionId});

  @override
  ConsumerState<_SessionNotesSheet> createState() => _SessionNotesSheetState();
}

class _SessionNotesSheetState extends ConsumerState<_SessionNotesSheet> {
  final _notesCtr = TextEditingController();
  String _mood = 'calm';
  int _attentionScore = 5;
  int _communicationScore = 5;
  int _motorScore = 5;
  int _behaviorScore = 5;

  static const _moods = ['sad', 'calm', 'happy', 'excited'];
  static const _moodEmojis = {
    'sad': '😢',
    'calm': '😐',
    'happy': '🙂',
    'excited': '😄',
  };

  @override
  void dispose() {
    _notesCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(sessionNotesProvider.notifier).submit(widget.sessionId, {
      'mood': _mood,
      'attention_score': _attentionScore,
      'communication_score': _communicationScore,
      'motor_score': _motorScore,
      'behavior_score': _behaviorScore,
      if (_notesCtr.text.trim().isNotEmpty) 'notes': _notesCtr.text.trim(),
    });
    if (mounted && ref.read(sessionNotesProvider).success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notes saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionNotesProvider);
    final r = Responsive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // ============================
        // Responsive Breakpoints
        // ============================

        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final horizontalPadding = isMobile ? 20.0 : 28.0;
        final titleSize = isMobile ? 24.0 : 28.0;
        final emojiSelected = isMobile ? 30.0 : 36.0;
        final emojiNormal = isMobile ? 22.0 : 28.0;

        return DraggableScrollableSheet(
          initialChildSize: isMobile ? 0.90 : 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),

              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 600,
                    ),

                    child: Padding(
                      // Keyboard-safe padding
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),

                      child: Column(
                        children: [
                          r.gapH(12, tablet: 16, desktop: 20),

                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),

                          Expanded(
                            child: ListView(
                              controller: controller,

                              padding: EdgeInsets.all(horizontalPadding),

                              children: [
                                Text(
                                  'Session Notes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontSize: titleSize),
                                ),

                                r.gapH(12, tablet: 16, desktop: 20),

                                Text(
                                  'Child Mood',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                r.gapH(12, tablet: 16, desktop: 20),

                                // ==========================
                                // Wrap prevents overflow
                                // ==========================
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  children: _moods.map((m) {
                                    final selected = _mood == m;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _mood = m;
                                        });
                                      },

                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),

                                        padding: const EdgeInsets.all(12),

                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.primaryBlue
                                                    .withValues(alpha: .12)
                                              : Colors.transparent,

                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),

                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _moodEmojis[m]!,
                                              style: TextStyle(
                                                fontSize: selected
                                                    ? emojiSelected
                                                    : emojiNormal,
                                              ),
                                            ),

                                            r.gapH(4),

                                            Text(
                                              m,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                r.gapH(28, tablet: 32, desktop: 36),

                                RatingSlider(
                                  label: 'Attention (1–10)',
                                  value: _attentionScore,
                                  onChanged: (v) {
                                    setState(() {
                                      _attentionScore = v;
                                    });
                                  },
                                ),

                                r.gapH(16, tablet: 20, desktop: 24),

                                RatingSlider(
                                  label: 'Communication (1–10)',
                                  value: _communicationScore,
                                  onChanged: (v) {
                                    setState(() {
                                      _communicationScore = v;
                                    });
                                  },
                                ),

                                r.gapH(16, tablet: 20, desktop: 24),

                                RatingSlider(
                                  label: 'Motor Skills (1–10)',
                                  value: _motorScore,
                                  onChanged: (v) {
                                    setState(() {
                                      _motorScore = v;
                                    });
                                  },
                                ),

                                r.gapH(16, tablet: 20, desktop: 24),

                                RatingSlider(
                                  label: 'Behavior (1–10)',
                                  value: _behaviorScore,
                                  onChanged: (v) {
                                    setState(() {
                                      _behaviorScore = v;
                                    });
                                  },
                                ),

                                r.gapH(24, tablet: 28, desktop: 32),

                                TextFormField(
                                  controller: _notesCtr,
                                  maxLines: 4,

                                  decoration: const InputDecoration(
                                    labelText: 'Notes (optional)',
                                    alignLabelWithHint: true,
                                  ),
                                ),

                                r.gapH(24, tablet: 28, desktop: 32),

                                if (state.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      state.error!,
                                      style: const TextStyle(
                                        color: AppColors.softCoral,
                                      ),
                                    ),
                                  ),

                                AppButton(
                                  label: 'Save Notes',
                                  loading: state.loading,
                                  onPressed: _submit,
                                ),

                                r.gapH(24, tablet: 28, desktop: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
