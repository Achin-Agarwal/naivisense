import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class ChildAdminCard extends StatelessWidget {
  final ChildModel child;

  const ChildAdminCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (severityLabel, severityColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('Unknown', AppColors.textSecondary),
    };

    String therapistName(String id, String? name) {
      if (name != null && name.isNotEmpty) return name;
      if (id.length <= 8) return id;
      return id.substring(0, 8);
    }

    return AppCard(
      onTap: () => context.push('/center-head/child/${child.id}', extra: child),

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
                backgroundColor: AppColors.centerHeadGradient.colors.first
                    .withValues(alpha: .12),
                child: Text(
                  child.name.isNotEmpty ? child.name[0].toUpperCase() : "?",
                  style: TextStyle(
                    color: AppColors.centerHeadGradient.colors.first,
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
                      toTitleCase(child.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(16),
                      ),
                    ),

                    SizedBox(height: r.h(3)),

                    Text(
                      "${child.ageYears} years",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: r.sp(12),
                      ),
                    ),

                    if (child.parentName != null)
                      Padding(
                        padding: EdgeInsets.only(top: r.h(2)),
                        child: Text(
                          "Parent: ${child.parentName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: r.sp(11),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(8),
                  vertical: r.h(4),
                ),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(r.radius(16)),
                ),
                child: Text(
                  severityLabel,
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(11),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: r.h(12)),

          Divider(height: 1),

          SizedBox(height: r.h(10)),

          /// DIAGNOSIS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.primaryBlue,
                size: r.icon(16),
              ),

              r.gapW(6),

              Expanded(
                child: Text(
                  child.diagnosis.isEmpty
                      ? "Diagnosis not available"
                      : child.diagnosis.join(", "),
                  style: TextStyle(fontSize: r.sp(12)),
                ),
              ),
            ],
          ),

          SizedBox(height: r.h(12)),

          Divider(height: 1),

          SizedBox(height: r.h(10)),

          /// ASSIGNED THERAPISTS
          /// ASSIGNED THERAPISTS
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: AppColors.mintGreen,
                size: r.icon(16),
              ),

              r.gapW(6),

              Expanded(
                child: Text(
                  "Assigned Therapists",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(14),
                  ),
                ),
              ),

              SizedBox(width: r.w(8)),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(8),
                  vertical: r.h(2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(r.radius(16)),
                ),
                child: Text(
                  "${child.therapists.length}",
                  style: TextStyle(
                    color: AppColors.mintGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(11),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: r.h(8)),

          if (child.therapists.isEmpty)
            Text(
              "No therapist assigned",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: r.sp(12),
              ),
            )
          else ...[
            ...child.therapists
                .take(2)
                .map(
                  (t) => Padding(
                    padding: EdgeInsets.only(bottom: r.h(6)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColors.primaryBlue,
                        ),

                        r.gapW(6),

                        Expanded(
                          child: Text(
                            therapistName(t.therapistId, t.therapistName),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: r.sp(13),
                            ),
                          ),
                        ),

                        if (t.therapyType.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.w(6),
                              vertical: r.h(2),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(r.radius(12)),
                            ),
                            child: Text(
                              t.therapyType,
                              style: TextStyle(fontSize: r.sp(10)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

            if (child.therapists.length > 2)
              InkWell(
                borderRadius: BorderRadius.circular(r.radius(8)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        "${child.name}'s Therapists",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: r.sp(18),
                        ),
                      ),
                      content: SizedBox(
                        width: r.isMobile ? double.maxFinite : 420,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: child.therapists.length,
                          separatorBuilder: (_, __) => Divider(height: r.h(16)),
                          itemBuilder: (_, index) {
                            final t = child.therapists[index];

                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,

                              leading: CircleAvatar(
                                radius: r.avatar(18),
                                backgroundColor: AppColors.mintGreen.withValues(
                                  alpha: .12,
                                ),
                                child: Text(
                                  therapistName(
                                    t.therapistId,
                                    t.therapistName,
                                  )[0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.mintGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: r.sp(13),
                                  ),
                                ),
                              ),

                              title: Text(
                                therapistName(t.therapistId, t.therapistName),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: r.sp(14),
                                ),
                              ),

                              subtitle: Text(
                                t.therapyType,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: r.sp(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(top: r.h(2)),
                  child: Text(
                    "+${child.therapists.length - 2} more",
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: r.sp(12),
                    ),
                  ),
                ),
              ),
          ],

          SizedBox(height: r.h(16)),
          const Divider(height: 1),
          SizedBox(height: r.h(16)),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: r.h(10)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(12)),
                ),
              ),
              onPressed: () =>
                  context.push('/center-head/child/${child.id}', extra: child),
              icon: Icon(
                Icons.description_outlined,
                size: r.icon(18),
                color: Colors.white,
              ),
              label: Text(
                "View Report",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: r.sp(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
