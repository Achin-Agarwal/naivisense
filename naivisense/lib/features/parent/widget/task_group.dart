import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/home_plan.dart';

import 'task_card.dart';

class TaskGroup extends ConsumerStatefulWidget {
  final String title;
  final List<HomePlanTask> tasks;
  final HomePlanModel plan;
  final Responsive responsive;

  const TaskGroup({
    super.key,
    required this.title,
    required this.tasks,
    required this.plan,
    required this.responsive,
  });

  @override
  ConsumerState<TaskGroup> createState() => _TaskGroupState();
}

class _TaskGroupState extends ConsumerState<TaskGroup> {
  final Set<String> _logged = {};

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: r.h(10), top: r.h(4)),
          child: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontSize: r.sp(15, tablet: 16, desktop: 17),
            ),
          ),
        ),

        ...widget.tasks.map(
          (task) => TaskCard(
            task: task,
            planId: widget.plan.id,
            logged: _logged.contains(task.taskId),
            onLogged: () {
              setState(() {
                _logged.add(task.taskId);
              });
            },
          ),
        ),

        r.gapH(10),
      ],
    );
  }
}
