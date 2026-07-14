import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/features/parent/widget/parent_child_card.dart';
import 'package:naivisense/features/parent/widget/parent_home_header.dart';
import 'package:naivisense/features/parent/widget/parent_stats_section.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/child.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../providers/parent_provider.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(parentChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,

        title: Text(
          "Hi, ${user?.name.split(' ').first ?? 'Parent'}",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: responsive.sp(20, tablet: 22, desktop: 24),
          ),
        ),

        actions: [
          IconButton(
            tooltip: "AI Assistant",
            icon: Icon(
              Icons.auto_awesome_outlined,
              size: responsive.icon(22, tablet: 24, desktop: 26),
            ),
            onPressed: () => context.go('/parent/chatbot'),
          ),

          IconButton(
            tooltip: "Logout",
            icon: Icon(
              Icons.logout,
              size: responsive.icon(22, tablet: 24, desktop: 26),
            ),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentChildrenProvider);
        },

        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          slivers: [
            //----------------------------------------------------------
            // HEADER
            //----------------------------------------------------------
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsive.maxWidth),
                  child: Padding(
                    padding: EdgeInsets.all(responsive.horizontalPadding),
                    child: ParentHomeHeader(
                      parentName: user?.name.split(' ').first ?? 'Parent',
                    ),
                  ),
                ),
              ),
            ),

            //----------------------------------------------------------
            // MAIN CONTENT
            //----------------------------------------------------------
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsive.maxWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentStatsSection(children: children),

                        responsive.gapH(28),

                        Text(
                          "Your Children",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsive.sp(
                                  24,
                                  tablet: 28,
                                  desktop: 30,
                                ),
                              ),
                        ),

                        responsive.gapH(18),

                        children.when(
                          loading: () => const sw.LoadingWidget(),

                          error: (e, _) =>
                              sw.ErrorWidget(message: e.toString()),

                          data: (list) {
                            if (list.isEmpty) {
                              return const sw.EmptyWidget(
                                message: "No children registered yet",
                                icon: Icons.child_care,
                              );
                            }

                            final crossAxisCount = responsive.isMobile
                                ? 1
                                : responsive.isTablet
                                ? 2
                                : 3;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: list.length,

                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: responsive.w(16),
                                    mainAxisSpacing: responsive.h(16),

                                    childAspectRatio: responsive.isMobile
                                        ? 0.95
                                        : responsive.isTablet
                                        ? 0.85
                                        : 0.80,
                                  ),

                              itemBuilder: (context, index) {
                                final ChildModel child = list[index];
                                return ParentChildCard(child: child);
                              },
                            );
                          },
                        ),

                        responsive.gapH(32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
