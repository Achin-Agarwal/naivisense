import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/therapist_overview.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class TherapistAdminCard extends StatefulWidget {
  final TherapistOverview therapist;

  const TherapistAdminCard({super.key, required this.therapist});

  @override
  State<TherapistAdminCard> createState() => _TherapistAdminCardState();
}

class _TherapistAdminCardState extends State<TherapistAdminCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final therapist = widget.therapist;
    final color = AppColors.mintGreen;

    final visibleChildren = _expanded
        ? therapist.children
        : therapist.children.take(2).toList();

    return AppCard(
      padding: EdgeInsets.all(r.w(16, tablet: 18, desktop: 20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: r.avatar(22, tablet: 24, desktop: 26),
                backgroundColor: color.withValues(alpha: .12),
                child: Text(
                  therapist.name.isNotEmpty
                      ? therapist.name[0].toUpperCase()
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
                      therapist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.sp(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: r.h(2)),

                    Text(
                      therapist.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: r.sp(12),
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
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(r.radius(18)),
                ),
                child: Text(
                  "${therapist.yearsExperience} yrs",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(10),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: r.h(12)),

          const Divider(height: 1),

          SizedBox(height: r.h(10)),

          /// Qualification
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.school_outlined, size: r.icon(16), color: color),

              r.gapW(6),

              Expanded(
                child: Text(
                  therapist.qualification.isEmpty
                      ? "Qualification not available"
                      : therapist.qualification,
                  style: TextStyle(fontSize: r.sp(12)),
                ),
              ),
            ],
          ),

          if (therapist.specialties.isNotEmpty) ...[
            SizedBox(height: r.h(12)),

            Wrap(
              spacing: r.w(6),
              runSpacing: r.h(6),
              children: therapist.specialties
                  .map(
                    (speciality) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.w(8),
                        vertical: r.h(4),
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(r.radius(16)),
                      ),
                      child: Text(
                        speciality,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: r.sp(11),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          SizedBox(height: r.h(12)),

          const Divider(height: 1),

          SizedBox(height: r.h(10)),

          /// CHILDREN HEADER
          Row(
            children: [
              Icon(Icons.child_care, color: color, size: r.icon(16)),

              r.gapW(6),

              Text(
                "Assigned Children",
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
                  "${therapist.children.length}",
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
          if (therapist.children.isEmpty)
            Text(
              "No assigned children",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: r.sp(12),
              ),
            )
          else
            ...visibleChildren.map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: r.h(8)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(10),
                    vertical: r.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(r.radius(12)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: r.avatar(14),
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: .12,
                        ),
                        child: Text(
                          child.name.isNotEmpty
                              ? child.name[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: r.sp(10),
                          ),
                        ),
                      ),

                      r.gapW(8),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toTitleCase(child.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: r.sp(13),
                              ),
                            ),

                            if (child.diagnosis.isNotEmpty)
                              Text(
                                child.diagnosis.join(", "),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: r.sp(11),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(width: r.w(6)),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.w(6),
                          vertical: r.h(3),
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(r.radius(12)),
                        ),
                        child: Text(
                          child.therapyType,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: r.sp(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (therapist.children.length > 2)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(
                  _expanded
                      ? "Show Less"
                      : "+${therapist.children.length - 2} more",
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
