import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/home_plan.dart';
import 'package:naivisense/features/parent/providers/parent_provider.dart';


class TaskCard extends ConsumerWidget {
  final HomePlanTask task;
  final String planId;
  final bool logged;
  final VoidCallback onLogged;

  const TaskCard({
    super.key,
    required this.task,
    required this.planId,
    required this.logged,
    required this.onLogged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);
    final state = ref.watch(taskLogProvider);

    return Container(
      margin: EdgeInsets.only(bottom: r.h(10)),
      padding: r.allPadding(14),
      decoration: BoxDecoration(
        color: logged
            ? AppColors.mintGreen.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: r.borderRadius(12),
        border: Border.all(
          color: logged
              ? AppColors.mintGreen.withValues(alpha: 0.30)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(
            task.icon,
            style: TextStyle(fontSize: r.icon(24, tablet: 26, desktop: 28)),
          ),

          r.gapW(14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: logged
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: logged ? TextDecoration.lineThrough : null,
                    fontSize: r.sp(15, tablet: 16, desktop: 17),
                  ),
                ),

                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),

                r.gapH(2),

                Text(
                  '${task.durationMin} min  •  ${task.frequency}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                  ),
                ),
              ],
            ),
          ),

          r.gapW(10),

          logged
              ? Icon(
                  Icons.check_circle,
                  color: AppColors.mintGreen,
                  size: r.icon(22, tablet: 24, desktop: 26),
                )
              : InkWell(
                  borderRadius: r.borderRadius(8),
                  onTap: state.loading
                      ? null
                      : () async {
                          final ok = await ref
                              .read(taskLogProvider.notifier)
                              .logTask(planId: planId, taskId: task.taskId);

                          if (ok) {
                            onLogged();
                          }
                        },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.w(14),
                      vertical: r.h(8),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.10),
                      borderRadius: r.borderRadius(8),
                      border: Border.all(
                        color: AppColors.mintGreen.withValues(alpha: 0.40),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.mintGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: r.sp(12, tablet: 13, desktop: 14),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
