import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/video_item.dart';

class VideoRow extends StatelessWidget {
  final VideoItemModel video;

  const VideoRow({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      margin: EdgeInsets.only(bottom: r.h(1.5)),
      padding: EdgeInsets.all(r.w(3.5)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Video icon
          Container(
            width: r.isMobile ? 52 : 58,
            height: r.isMobile ? 52 : 58,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.primaryBlue,
              size: r.icon(28),
            ),
          ),

          r.gapW(3),

          /// Video information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.sp(15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (!video.isParentVisible)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warmYellow.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Internal",
                          style: TextStyle(
                            color: AppColors.warmYellow,
                            fontSize: r.sp(10),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                r.gapH(.5),

                /// Category
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: r.icon(14),
                      color: AppColors.textSecondary,
                    ),
                   r.gapW(4),
                    Expanded(
                      child: Text(
                        video.categoryLabel,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: r.sp(12),
                        ),
                      ),
                    ),
                  ],
                ),

                if (video.description != null &&
                    video.description!.trim().isNotEmpty) ...[
                  r.gapH(.8),
                  Text(
                    video.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontSize: r.sp(12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
