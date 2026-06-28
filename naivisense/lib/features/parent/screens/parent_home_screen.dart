import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../providers/parent_provider.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(parentChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Parent'}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'AI Chat',
            onPressed: () => context.go('/parent/chatbot'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(parentChildrenProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, user?.name ?? '')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStats(context, children),
                  const SizedBox(height: 24),
                  Text('Your Children',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  children.when(
                    loading: () => const sw.LoadingWidget(),
                    error:   (e, _) => sw.ErrorWidget(message: e.toString()),
                    data:    (list) {
                      if (list.isEmpty) {
                        return const sw.EmptyWidget(
                          message: 'No children registered yet',
                          icon: Icons.child_care,
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ChildSummaryCard(child: list[i]),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.parentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70)),
                Text(name.split(' ').first,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(AppDateUtils.formatDate(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.family_restroom, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, AsyncValue<List<ChildModel>> children) {
    final count = children.valueOrNull?.length ?? 0;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Children',
            value: '$count',
            icon: Icons.child_care,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Active Plans',
            value: '$count',
            icon: Icons.assignment_outlined,
            color: AppColors.mintGreen,
          ),
        ),
      ],
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Child summary card (on home) ──────────────────────────────────────────────

class _ChildSummaryCard extends ConsumerWidget {
  final ChildModel child;
  const _ChildSummaryCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(parentSessionsProvider(child.id));
    final plan     = ref.watch(parentActivePlanProvider(child.id));

    final upcoming = sessions.valueOrNull
        ?.where((s) => s.status == 'scheduled' && s.scheduledAt.isAfter(DateTime.now()))
        .toList()
      ?..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return AppCard(
      onTap: () => context.push('/parent/child/${child.id}', extra: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.mintGreen.withValues(alpha: 0.15),
                child: Text(child.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.mintGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(
                      '${child.ageYears} yrs  •  ${child.diagnosis.join(', ')}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _SeverityBadge(severity: child.severity),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.assignment_outlined,
                  label: plan.valueOrNull != null
                      ? '${plan.valueOrNull!.tasks.length} tasks this week'
                      : 'No active plan',
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  icon: Icons.event_outlined,
                  label: (upcoming?.isNotEmpty ?? false)
                      ? AppDateUtils.formatDate(upcoming!.first.scheduledAt)
                      : 'No upcoming session',
                  color: AppColors.mintGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  context.push('/parent/child/${child.id}', extra: child),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      'mild'         => ('Mild', AppColors.mintGreen),
      'moderate'     => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _              => ('—', AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 12, color: color),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
