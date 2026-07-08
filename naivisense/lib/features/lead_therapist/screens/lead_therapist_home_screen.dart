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
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(ltChildrenProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        final horizontalPadding = isMobile ? 16.0 : 24.0;
        final sectionSpacing = isMobile ? 12.0 : 16.0;

        Widget body = RefreshIndicator(
          onRefresh: () async => ref.invalidate(ltChildrenProvider),
          child: children.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(
              child: Text(
                'Could not load children',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No children in system',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView(
                padding: EdgeInsets.all(horizontalPadding),
                children: [
                  _SectionHeader(
                    title: 'Concern Review Queue',
                    icon: Icons.assignment_late_outlined,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: sectionSpacing),
                  ...list.map(
                    (c) => _ChildConcernCard(child: c, isMobile: isMobile),
                  ),
                ],
              );
            },
          ),
        );

        // Center and constrain content on tablet/desktop
        if (!isMobile) {
          body = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: body,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              'Hi, ${user?.name.split(' ').first ?? 'Lead Therapist'}',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, size: isMobile ? 22 : 24),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isMobile;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isMobile ? 16.0 : 18.0;
    final iconSize = isMobile ? 20.0 : 24.0;

    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: iconSize),
        SizedBox(width: isMobile ? 8 : 10),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildConcernCard extends ConsumerWidget {
  final ChildModel child;
  final bool isMobile;

  const _ChildConcernCard({required this.child, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concerns = ref.watch(ltAllOpenConcernsProvider(child.id));

    return concerns.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        final avatarRadius = isMobile ? 16.0 : 20.0;
        final avatarFontSize = isMobile ? 13.0 : 15.0;
        final nameFontSize = isMobile ? 14.0 : 16.0;

        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 14 : 18,
                  isMobile ? 12 : 16,
                  isMobile ? 14 : 18,
                  8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: AppColors.primaryBlue.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        child.name[0].toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: avatarFontSize,
                        ),
                      ),
                    ),

                    SizedBox(width: isMobile ? 10 : 14),

                    // Prevent overflow on long names
                    Expanded(
                      child: Text(
                        child.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: nameFontSize,
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softCoral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${list.length} open',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softCoral,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              ...list
                  .take(3)
                  .map((c) => _ConcernRow(concern: c, childId: child.id)),

              if (list.length > 3)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 14 : 18,
                    0,
                    isMobile ? 14 : 18,
                    isMobile ? 10 : 14,
                  ),
                  child: Text(
                    '+ ${list.length - 3} more',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: AppColors.textSecondary,
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

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    // Responsive values
    final horizontalPadding = isMobile ? 14.0 : 18.0;
    final topPadding = isMobile ? 10.0 : 14.0;
    final iconSize = isMobile ? 15.0 : 18.0;
    final categoryFontSize = isMobile ? 10.0 : 11.0;
    final descriptionFontSize = isMobile ? 13.0 : 14.0;
    final buttonFontSize = isMobile ? 12.0 : 14.0;
    final buttonPaddingH = isMobile ? 14.0 : 18.0;
    final buttonPaddingV = isMobile ? 8.0 : 10.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: iconSize,
                  color: AppColors.softCoral,
                ),

                const SizedBox(width: 8),

                // Expanded prevents text overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.concern.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: categoryFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softCoral,
                        ),
                      ),

                      Text(
                        widget.concern.description,
                        maxLines: _expanded ? null : 1,
                        overflow: _expanded ? null : TextOverflow.ellipsis,
                        style: TextStyle(fontSize: descriptionFontSize),
                      ),
                    ],
                  ),
                ),

                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: isMobile ? 16 : 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          if (_expanded) ...[
            const SizedBox(height: 8),

            // Responsive form field
            TextFormField(
              controller: _resolutionCtrl,
              decoration: const InputDecoration(
                hintText: 'Add guidance note...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 8),

            // Prevent button overflow on smaller screens
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
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonPaddingH,
                    vertical: buttonPaddingV,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Resolve',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
