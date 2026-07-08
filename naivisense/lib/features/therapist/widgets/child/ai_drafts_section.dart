import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/ai_draft.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/repositories/ai_repository.dart';
import 'package:naivisense/features/therapist/providers/therapist_provider.dart';
import 'package:naivisense/features/therapist/widgets/child/ai_button.dart';
import 'package:naivisense/features/therapist/widgets/child/ai_draft_bottom_sheet.dart';
import 'package:naivisense/features/therapist/widgets/child/empty_message.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

class AiDraftsSection extends ConsumerWidget {
  final ChildModel child;
  final AsyncValue<List<AiDraftModel>> aiDrafts;

  const AiDraftsSection({
    super.key,
    required this.child,
    required this.aiDrafts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive=Responsive(context);
    return ProfileCard(
      title: 'AI Plans & Insights',
      icon: Icons.auto_awesome_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AiButton(
                label: 'Therapy Plan',
                onTap: () => _generateAi(context, ref, 'therapy_plan'),
              ),
              AiButton(
                label: 'Home Plan',
                onTap: () => _generateAi(context, ref, 'home_plan'),
              ),
              AiButton(
                label: 'Activities',
                onTap: () =>
                    _generateAi(context, ref, 'reinforcement_activities'),
              ),
              AiButton(
                label: 'Insights',
                onTap: () => _generateAi(context, ref, 'insights'),
              ),
            ],
          ),
          
          responsive.gapH(12, tablet: 16, desktop: 20),

          const Divider(height: 1),
          responsive.gapH(12, tablet: 16, desktop: 20),
          aiDrafts.when(
            loading: () => SizedBox(
              height: responsive.h(42, tablet: 46, desktop: 48),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            error: (_, _) => EmptyMessage(message: 'Could not load drafts'),
            data: (list) {
              if (list.isEmpty) {
                return EmptyMessage(message: 'No AI drafts yet — tap a button above');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length > 5 ? 5 : list.length,
                separatorBuilder: (_, _) => Divider(height: responsive.h(12, tablet: 16, desktop: 20)),
                itemBuilder: (_, i) => AiDraftRow(
                  draft: list[i],
                  onApprove: () async {
                    await ref
                        .read(aiRepositoryProvider)
                        .approveDraft(list[i].id);
                    ref.invalidate(therapistAiDraftsProvider(child.id));
                  },
                  onView: () => _showDraftContent(context, list[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateAi(
    BuildContext context,
    WidgetRef ref,
    String type,
  ) async {
    final notifier = ref.read(aiGenerateProvider.notifier);
    await notifier.generate(child.id, type);
    final state = ref.read(aiGenerateProvider);
    if (state.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: AppColors.softCoral,
        ),
      );
    } else if (state.draft != null && context.mounted) {
      ref.invalidate(therapistAiDraftsProvider(child.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI draft generated successfully')),
      );
      _showDraftContent(context, state.draft!);
    }
  }

  void _showDraftContent(BuildContext context, AiDraftModel draft) {
    final media = MediaQuery.of(context);
    final responsive = Responsive(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Center(
          // Responsive form-like content width for larger screens.
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.w(600, tablet: 700, desktop: 800)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.w(16, tablet: 24, desktop: 32),
                responsive.h(16, tablet: 24, desktop: 32),
                responsive.w(16, tablet: 24, desktop: 32),
                media.viewInsets.bottom + responsive.h(16, tablet: 24, desktop: 32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  responsive.gapH(16, tablet: 24, desktop: 32),
                  Text(
                    draft.typeLabel,
                    style: TextStyle(
                      fontSize: responsive.text(24, tablet: 28, desktop: 32),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  responsive.gapH(8, tablet: 12, desktop: 16),
                  Text(
                    '${draft.isApproved ? "Approved" : "Pending"} • ${draft.modelUsed}',
                    style: TextStyle(
                      fontSize: responsive.text(14, tablet: 16, desktop: 18),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Divider(height: responsive.h(16, tablet: 24, desktop: 32)),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        draft.content,
                        style: TextStyle(fontSize: responsive.text(16, tablet: 18, desktop: 20), height: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}
