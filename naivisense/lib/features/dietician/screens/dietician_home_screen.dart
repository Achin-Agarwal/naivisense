import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/dietician_provider.dart';
import 'dietician_child_profile_screen.dart';

class DieticianHomeScreen extends ConsumerWidget {
  const DieticianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).valueOrNull?.user;
    final requests = ref.watch(dieticianRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Dietician'}'),
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
        onRefresh: () async => ref.invalidate(dieticianRequestsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              title: 'Diet Plan Requests',
              icon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 12),
            requests.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const _EmptyHint('Could not load requests'),
              data: (list) {
                if (list.isEmpty) {
                  return const _EmptyHint('No diet plan requests assigned to you');
                }
                return Column(
                  children: list
                      .map((r) => _RequestCard(
                            request: r,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DieticianChildProfileScreen(
                                  childId: r.childId,
                                  requestId: r.id,
                                ),
                              ),
                            ),
                            onAccept: () async {
                              await ref
                                  .read(updateDietRequestProvider.notifier)
                                  .update(r.id, {'status': 'accepted'});
                            },
                            onComplete: () async {
                              await ref
                                  .read(updateDietRequestProvider.notifier)
                                  .update(r.id, {'status': 'completed'});
                            },
                          ))
                      .toList(),
                );
              },
            ),
          ],
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

class _RequestCard extends StatelessWidget {
  final dynamic request;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onComplete;
  const _RequestCard({
    required this.request,
    required this.onTap,
    required this.onAccept,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status as String) {
      'requested'   => AppColors.warmYellow,
      'accepted'    => AppColors.primaryBlue,
      'in_progress' => AppColors.primaryBlue,
      'completed'   => AppColors.mintGreen,
      _             => AppColors.textSecondary,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.reason as String,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(request.statusLabel as String,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ],
            ),
            if (request.notes != null && (request.notes as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(request.notes as String,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            if (request.status == 'requested') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Accept Request',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ] else if (request.status == 'in_progress') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Mark Completed',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(message,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13)),
    );
  }
}
