import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../../../data/models/therapist_overview.dart';
import '../../../data/models/user.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../providers/center_head_provider.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';

String _shortIdOrFallback(String id, String fallback) {
  if (id.isEmpty) return fallback;
  return id.length <= 8 ? id : id.substring(0, 8);
}

class CenterHeadHomeScreen extends ConsumerWidget {
  const CenterHeadHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(centerChildrenProvider);
    final therapists = ref.watch(therapistsOverviewProvider);
    final parents = ref.watch(allParentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(user?.name ?? 'Center Head'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.payments_outlined),
            tooltip: 'Payments',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'enroll_therapist',
            onPressed: () => context.push('/center-head/enroll-therapist'),
            backgroundColor: AppColors.mintGreen,
            icon: const Icon(Icons.psychology_outlined, color: Colors.white),
            label: const Text(
              'Enroll Therapist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'register_parent',
            onPressed: () => context.push('/center-head/enroll-parent'),
            backgroundColor: const Color(0xFF9B59B6),
            icon: const Icon(Icons.family_restroom, color: Colors.white),
            label: const Text(
              'Register Parent',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'enroll_child',
            onPressed: () => context.push('/center-head/enroll'),
            backgroundColor: AppColors.primaryBlue,
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            label: const Text(
              'Enroll Child',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(centerChildrenProvider);
          ref.invalidate(therapistsOverviewProvider);
          ref.invalidate(allParentsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGradientHeader(context, user?.name ?? ''),
                  const SizedBox(height: 20),
                  _buildStats(context, children, therapists, parents),
                  const SizedBox(height: 24),
                  _buildTherapistsSection(context, therapists),
                  const SizedBox(height: 24),
                  _buildParentsSection(context, parents),
                  const SizedBox(height: 24),
                  _buildChildrenSection(context, children),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.centerHeadGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Center Dashboard',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Overview of all therapists and children',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    AsyncValue<List<ChildModel>> children,
    AsyncValue<List<TherapistOverview>> therapists,
    AsyncValue<List<UserModel>> parents,
  ) {
    final childCount = children.valueOrNull?.length ?? 0;
    final therapistCount = therapists.valueOrNull?.length ?? 0;
    final parentCount = parents.valueOrNull?.length ?? 0;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        StatTile(
          label: 'Children',
          value: '$childCount',
          icon: Icons.child_care,
          iconColor: AppColors.primaryBlue,
        ),
        StatTile(
          label: 'Therapists',
          value: '$therapistCount',
          icon: Icons.medical_services_outlined,
          iconColor: AppColors.mintGreen,
        ),
        StatTile(
          label: 'Parents',
          value: '$parentCount',
          icon: Icons.family_restroom,
          iconColor: const Color(0xFF9B59B6),
        ),
      ],
    );
  }

  Widget _buildParentsSection(
    BuildContext context,
    AsyncValue<List<UserModel>> parents,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parents', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        parents.when(
          loading: () => const sw.LoadingWidget(),
          error: (e, _) => sw.ErrorWidget(message: e.toString()),
          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No parents registered yet',
                icon: Icons.family_restroom,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ParentAdminCard(parent: list[i]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTherapistsSection(
    BuildContext context,
    AsyncValue<List<TherapistOverview>> therapists,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Therapists', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        therapists.when(
          loading: () => const sw.LoadingWidget(),
          error: (e, _) => sw.ErrorWidget(message: e.toString()),
          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No therapists registered yet',
                icon: Icons.medical_services_outlined,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _TherapistAdminCard(therapist: list[i]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChildrenSection(
    BuildContext context,
    AsyncValue<List<ChildModel>> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Children', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        children.when(
          loading: () => const sw.LoadingWidget(),
          error: (e, _) => sw.ErrorWidget(message: e.toString()),
          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No children enrolled yet',
                icon: Icons.child_care,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ChildAdminCard(child: list[i]),
            );
          },
        ),
      ],
    );
  }
}

// ── Therapist Admin Card ──────────────────────────────────────────────────

class _TherapistAdminCard extends StatefulWidget {
  final TherapistOverview therapist;
  const _TherapistAdminCard({required this.therapist});

  @override
  State<_TherapistAdminCard> createState() => _TherapistAdminCardState();
}

class _TherapistAdminCardState extends State<_TherapistAdminCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.therapist;
    final specialties = [...t.specialties, ...t.therapyMethods];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.therapistGradient.colors.first
                        .withValues(alpha: 0.15),
                    child: Text(
                      t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppColors.therapistGradient.colors.first,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (t.qualification.isNotEmpty)
                          Text(
                            t.qualification,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          '${t.yearsExperience > 0 ? '${t.yearsExperience} yrs exp' : 'Exp not set'}  •  ${t.children.length} child${t.children.length == 1 ? '' : 'ren'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Specialties chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: specialties.isEmpty
                ? Text(
                    'No specialties listed',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: specialties
                        .map((s) => _SpecialtyChip(label: s))
                        .toList(),
                  ),
          ),

          // Expanded children list
          if (_expanded && t.children.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                'Assigned Children',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...t.children.map(
              (c) => _AssignedChildRow(child: c, showTherapyType: true),
            ),
            const SizedBox(height: 8),
          ],

          if (_expanded && t.children.isEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No children assigned yet',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  const _SpecialtyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _AssignedChildRow extends StatelessWidget {
  final TherapistChildSummary child;
  final bool showTherapyType;
  const _AssignedChildRow({required this.child, this.showTherapyType = false});

  @override
  Widget build(BuildContext context) {
    final (sevLabel, sevColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.child_care,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  showTherapyType && child.therapyType.isNotEmpty
                      ? '${child.therapyType}  •  ${child.diagnosis.join(', ')}'
                      : child.diagnosis.join(', '),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: sevColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sevColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              sevLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: sevColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Child Admin Card ──────────────────────────────────────────────────────

class _ChildAdminCard extends StatelessWidget {
  final ChildModel child;
  const _ChildAdminCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final (sevLabel, sevColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };

    return AppCard(
      onTap: () => context.push('/center-head/child/${child.id}', extra: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.centerHeadGradient.colors.first
                    .withValues(alpha: 0.15),
                child: Text(
                  child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.centerHeadGradient.colors.first,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${child.ageYears} yrs  •  ${child.diagnosis.join(', ')}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sevColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  sevLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: sevColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (child.therapists.isEmpty)
            Row(
              children: [
                const Icon(
                  Icons.person_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Not assigned',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 2),
                const Text(
                  'View Report',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...child.therapists.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${t.therapistName ?? _shortIdOrFallback(t.therapistId, 'Unassigned therapist')}'
                            '${t.therapyType.isNotEmpty ? "  ·  ${t.therapyType}" : ""}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'View Report',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Parent Admin Card ─────────────────────────────────────────────────────

class _ParentAdminCard extends StatelessWidget {
  final UserModel parent;
  const _ParentAdminCard({required this.parent});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.parentGradient.colors.first.withValues(
              alpha: 0.15,
            ),
            child: Text(
              parent.name.isNotEmpty ? parent.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.parentGradient.colors.first,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parent.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  parent.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.parentGradient.colors.first.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.parentGradient.colors.first.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Text(
              'Parent',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.parentGradient.colors.first,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
