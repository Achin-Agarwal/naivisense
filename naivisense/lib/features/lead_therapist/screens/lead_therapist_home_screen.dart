import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../../../data/models/concern.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/lead_therapist_provider.dart';

class LeadTherapistHomeScreen extends ConsumerWidget {
  const LeadTherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(ltChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Lead Therapist'}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(ltChildrenProvider),
        child: children.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
              child: Text('Could not load children',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                  child: Text('No children in system',
                      style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader(
                    title: 'Concern Review Queue',
                    icon: Icons.assignment_late_outlined),
                const SizedBox(height: 12),
                ...list.map((c) => _ChildConcernCard(child: c)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _ChildConcernCard extends ConsumerWidget {
  final ChildModel child;
  const _ChildConcernCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concerns = ref.watch(ltAllOpenConcernsProvider(child.id));

    return concerns.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.12),
                      child: Text(child.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    Text(child.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.softCoral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${list.length} open',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softCoral)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...list.take(3).map((c) => _ConcernRow(
                    concern: c,
                    childId: child.id,
                  )),
              if (list.length > 3)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Text('+ ${list.length - 3} more',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ConcernRow extends ConsumerStatefulWidget {
  final ConcernModel concern;
  final String childId;
  const _ConcernRow({required this.concern, required this.childId});

  @override
  ConsumerState<_ConcernRow> createState() => _ConcernRowState();
}

class _ConcernRowState extends ConsumerState<_ConcernRow> {
  final _resolutionCtrl = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _resolutionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resolveConcernProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.report_problem_outlined,
                    size: 15, color: AppColors.softCoral),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.concern.category.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softCoral)),
                      Text(widget.concern.description,
                          maxLines: _expanded ? null : 1,
                          overflow: _expanded
                              ? null
                              : TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _resolutionCtrl,
              decoration: const InputDecoration(
                hintText: 'Add guidance note...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: state.loading
                    ? null
                    : () async {
                        if (_resolutionCtrl.text.trim().isEmpty) return;
                        final ok = await ref
                            .read(resolveConcernProvider.notifier)
                            .resolve(
                              widget.concern.id,
                              widget.childId,
                              _resolutionCtrl.text.trim(),
                            );
                        if (ok && mounted) {
                          setState(() => _expanded = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Resolve',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
