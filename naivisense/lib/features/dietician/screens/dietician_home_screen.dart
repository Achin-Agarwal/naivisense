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
    final user = ref.watch(authProvider).valueOrNull?.user;
    final requests = ref.watch(dieticianRequestsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // =====================================
        // Responsive Breakpoints
        // =====================================

        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final horizontalPadding = isMobile ? 16.0 : 24.0;

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            title: Text(
              'Hi, ${user?.name.split(' ').first ?? 'Dietician'}',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, size: isMobile ? 22 : 26),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dieticianRequestsProvider);
            },

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),

                child: ListView(
                  padding: EdgeInsets.all(horizontalPadding),

                  children: [
                    _SectionHeader(
                      title: "Diet Plan Requests",
                      icon: Icons.assignment_outlined,
                    ),

                    SizedBox(height: isMobile ? 12 : 20),

                    requests.when(
                      loading: () => const LinearProgressIndicator(),

                      error: (_, __) =>
                          const _EmptyHint("Could not load requests"),

                      data: (list) {
                        if (list.isEmpty) {
                          return const _EmptyHint(
                            "No diet plan requests assigned to you",
                          );
                        }

                        return Column(
                          children: list.map((r) {
                            return _RequestCard(
                              request: r,

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DieticianChildProfileScreen(
                                      childId: r.childId,
                                      requestId: r.id,
                                    ),
                                  ),
                                );
                              },

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
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: isMobile ? 20 : 24),

        SizedBox(width: isMobile ? 8 : 12),

        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// =======================================================
// Responsive Request Card
// =======================================================

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
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final statusColor = switch (request.status as String) {
      'requested' => AppColors.warmYellow,
      'accepted' => AppColors.primaryBlue,
      'in_progress' => AppColors.primaryBlue,
      'completed' => AppColors.mintGreen,
      _ => AppColors.textSecondary,
    };

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),

        padding: EdgeInsets.all(isMobile ? 14 : 20),

        decoration: BoxDecoration(
          color: AppColors.surface,

          borderRadius: BorderRadius.circular(isMobile ? 14 : 18),

          border: Border.all(color: AppColors.divider),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================
            // Responsive Header
            // =====================================
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,

              children: [
                SizedBox(
                  width: isMobile
                      ? width * 0.58
                      : isTablet
                      ? 420
                      : 520,

                  child: Text(
                    request.reason as String,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 10,
                    vertical: isMobile ? 4 : 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .10),

                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Text(
                    request.statusLabel as String,

                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            // =====================================
            // Notes
            // =====================================
            if (request.notes != null &&
                (request.notes as String).isNotEmpty) ...[
              SizedBox(height: isMobile ? 8 : 10),

              Text(
                request.notes as String,

                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            // =====================================
            // Action Button
            // =====================================
            if (request.status == 'requested') ...[
              SizedBox(height: isMobile ? 14 : 18),

              SizedBox(
                width: double.infinity,
                height: isMobile ? 42 : 48,

                child: ElevatedButton(
                  onPressed: onAccept,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: Text(
                    "Accept Request",

                    style: TextStyle(fontSize: isMobile ? 13 : 15),
                  ),
                ),
              ),
            ] else if (request.status == 'in_progress') ...[
              SizedBox(height: isMobile ? 14 : 18),

              SizedBox(
                width: double.infinity,
                height: isMobile ? 42 : 48,

                child: ElevatedButton(
                  onPressed: onComplete,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: Text(
                    "Mark Completed",

                    style: TextStyle(fontSize: isMobile ? 13 : 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =======================================================
// Responsive Empty Hint
// =======================================================

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint(this.message);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;

    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(isMobile ? 16 : 22),

      decoration: BoxDecoration(
        color: AppColors.background,

        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),

        border: Border.all(color: AppColors.divider),
      ),

      child: Text(
        message,
        textAlign: TextAlign.center,

        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: isMobile ? 13 : 15,
        ),
      ),
    );
  }
}
