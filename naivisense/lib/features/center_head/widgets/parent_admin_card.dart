import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/user.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class ParentAdminCard extends StatefulWidget {
  final UserModel parent;
  final List<ChildModel> children;

  const ParentAdminCard({
    super.key,
    required this.parent,
    required this.children,
  });

  @override
  State<ParentAdminCard> createState() => _ParentAdminCardState();
}

class _ParentAdminCardState extends State<ParentAdminCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final color = AppColors.parentGradient.colors.first;

    final visibleChildren = _expanded
        ? widget.children
        : widget.children.take(2).toList();

    return AppCard(
      padding: EdgeInsets.all(r.w(16, tablet: 18, desktop: 20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: r.avatar(22, tablet: 24, desktop: 26),
                backgroundColor: color.withValues(alpha: .12),
                child: Text(
                  widget.parent.name.isNotEmpty
                      ? widget.parent.name[0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(17),
                  ),
                ),
              ),

              r.gapW(10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toTitleCase(widget.parent.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.sp(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: r.h(2)),

                    Text(
                      widget.parent.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.sp(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(8),
                  vertical: r.h(3),
                ),
                decoration: BoxDecoration(
                  color: widget.parent.isActive
                      ? Colors.green.withValues(alpha: .12)
                      : Colors.red.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(r.radius(18)),
                ),
                child: Text(
                  widget.parent.isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    fontSize: r.sp(10),
                    fontWeight: FontWeight.w600,
                    color: widget.parent.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: r.h(10)),
          const Divider(height: 1),
          SizedBox(height: r.h(10)),

          /// Children Header
          Row(
            children: [
              Icon(Icons.child_care, color: color, size: r.icon(16)),

              r.gapW(6),

              Text(
                "Children",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: r.sp(14),
                ),
              ),

              const Spacer(),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(8),
                  vertical: r.h(2),
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(r.radius(16)),
                ),
                child: Text(
                  "${widget.children.length}",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(11),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: r.h(8)),

          if (widget.children.isEmpty)
            Text(
              "No children enrolled",
              style: TextStyle(
                fontSize: r.sp(12),
                color: AppColors.textSecondary,
              ),
            )
          else
            ...visibleChildren.map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: r.h(6)),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: r.icon(6),
                      color: AppColors.primaryBlue,
                    ),

                    r.gapW(6),

                    Expanded(
                      child: Text(
                        toTitleCase(child.name),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.sp(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Text(
                      "${child.ageYears}y",
                      style: TextStyle(
                        fontSize: r.sp(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (widget.children.length > 2)
            InkWell(
              borderRadius: BorderRadius.circular(r.radius(8)),
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: r.h(4)),
                child: Text(
                  _expanded
                      ? "Show Less"
                      : "+${widget.children.length - 2} more",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
