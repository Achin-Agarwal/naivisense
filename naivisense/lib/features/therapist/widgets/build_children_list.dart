import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../screens/therapist_child_profile_screen.dart';

class ChildrenListSection extends StatelessWidget {
  final AsyncValue<List<ChildModel>> children;

  const ChildrenListSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Children',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: r.sp(20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.w700,
          ),
        ),

        r.gapH(16),

        children.when(
          loading: () => const sw.LoadingWidget(),
          error: (e, _) => sw.ErrorWidget(message: e.toString()),
          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No children assigned yet',
                icon: Icons.child_care,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => r.gapH(12),
              itemBuilder: (_, i) => ChildTile(child: list[i]),
            );
          },
        ),
      ],
    );
  }
}

class ChildTile extends StatelessWidget {
  final ChildModel child;

  const ChildTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TherapistChildProfileScreen(child: child),
            ),
          );
        },
        child: Padding(
          padding: r.allPadding(2),
          child: Row(
            children: [
              // Avatar
              Container(
                width: r.w(52, tablet: 58, desktop: 64),
                height: r.w(52, tablet: 58, desktop: 64),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    child.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: r.sp(20, tablet: 22, desktop: 24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),

              r.gapW(16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toTitleCase(child.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: r.sp(16, tablet: 18, desktop: 20),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    r.gapH(8),

                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: r.icon(16),
                          color: AppColors.textSecondary,
                        ),

                        r.gapW(4),

                        Text(
                          '${child.ageYears} yrs',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: r.sp(13),
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),

                    r.gapH(8),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.w(10),
                        vertical: r.h(5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(r.radius(20)),
                      ),
                      child: Text(
                        child.diagnosis.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.sp(12),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              r.gapW(12),

              Container(
                width: r.w(40),
                height: r.w(40),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: r.icon(16),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
