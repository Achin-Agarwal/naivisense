import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/user.dart';

import '../../../core/utils/responsive.dart';
import '../../../../shared/widgets/state_widgets.dart' as sw;
import 'parent_admin_card.dart';

class ParentsSection extends StatelessWidget {
  final AsyncValue<List<UserModel>> parents;
  final AsyncValue<List<ChildModel>> children;

  const ParentsSection({
    super.key,
    required this.parents,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parents',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: r.sp(24, tablet: 26, desktop: 28),
          ),
        ),

        r.gapH(12, tablet: 16, desktop: 20),

        parents.when(
          loading: () => const sw.LoadingWidget(),
          error: (e, _) => sw.ErrorWidget(message: e.toString()),
          data: (parentList) {
            return children.when(
              loading: () => const sw.LoadingWidget(),
              error: (e, _) => sw.ErrorWidget(message: e.toString()),
              data: (allChildren) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int columns;

                    if (r.isDesktop) {
                      columns = 3;
                    } else if (r.isTablet) {
                      columns = 2;
                    } else {
                      columns = 1;
                    }

                    final spacing = r.w(16);
                    final cardWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: r.h(16),
                      children: parentList.map((parent) {
                        final parentChildren = allChildren
                            .where((c) => c.parentId == parent.id)
                            .toList();

                        return SizedBox(
                          width: cardWidth,
                          child: ParentAdminCard(
                            parent: parent,
                            children: parentChildren,
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
