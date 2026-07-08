import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';


class ChildDetailAppBar extends StatelessWidget {
  final ChildModel child;

  const ChildDetailAppBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final expandedHeight = r.h(
      220,
      tablet: 250,
      desktop: 280,
    );

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: const Color(0xFF2AAD7E),

      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: r.icon(
            22,
            tablet: 24,
            desktop: 26,
          ),
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.parentGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                r.horizontalPadding,
                r.verticalPadding + r.h(18),
                r.horizontalPadding,
                r.verticalPadding,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: r.avatar(
                      34,
                      tablet: 40,
                      desktop: 46,
                    ),
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(
                          22,
                          tablet: 26,
                          desktop: 30,
                        ),
                      ),
                    ),
                  ),

                  r.gapW(16),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: r.sp(
                              24,
                              tablet: 28,
                              desktop: 32,
                            ),
                          ),
                        ),

                        r.gapH(4),

                        Text(
                          '${child.ageYears} years old',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: r.sp(
                              14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}