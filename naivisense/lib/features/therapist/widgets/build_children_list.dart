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
    final responsive = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Children',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: responsive.sp(20, tablet: 22, desktop: 24),
          ),
        ),

        responsive.gapH(12, tablet: 16, desktop: 20),

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
              separatorBuilder: (_, __) =>
                  responsive.gapH(8, tablet: 10, desktop: 12),
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
    final responsive = Responsive(context);

    return AppCard(
      onTap: () {},

      child: Row(
        children: [
          CircleAvatar(
            radius: responsive.avatar(20, tablet: 22, desktop: 24),
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            child: Text(
              child.name[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: responsive.sp(14, tablet: 16, desktop: 18),
              ),
            ),
          ),

          responsive.gapW(12, tablet: 16, desktop: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toTitleCase(child.name),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: responsive.sp(14, tablet: 16, desktop: 18),
                  ),
                ),

                responsive.gapH(2, tablet: 3, desktop: 4),

                Text(
                  '${child.ageYears} yrs • ${child.diagnosis}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                  ),
                ),
              ],
            ),
          ),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TherapistChildProfileScreen(child: child),
                  ),
                );
              },
              icon: Icon(
                Icons.chevron_right,
                size: responsive.icon(20, tablet: 22, desktop: 24),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
