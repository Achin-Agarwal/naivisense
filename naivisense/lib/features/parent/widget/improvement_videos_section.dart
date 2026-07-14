import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/video_item.dart';
import 'package:naivisense/features/parent/widget/empty_hint.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/features/parent/widget/video_upload_button.dart';

class ImprovementVideosSection extends StatelessWidget {
  final String childId;
  final AsyncValue<List<VideoItemModel>> videos;

  const ImprovementVideosSection({
    super.key,
    required this.childId,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final crossAxisCount = r.isDesktop
        ? 3
        : r.isTablet
        ? 2
        : 1;

    final childAspectRatio = r.isDesktop
        ? 3.2
        : r.isTablet
        ? 3.0
        : 2.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: SectionHeader(
                title: 'Videos',
                icon: Icons.videocam_outlined,
              ),
            ),

            VideoUploadButton(childId: childId),
          ],
        ),

        r.gapH(16),

        videos.when(
          loading: () => const LinearProgressIndicator(),

          error: (_, __) => EmptyHint(message: 'Could not load videos'),

          data: (videoList) {
            if (videoList.isEmpty) {
              return EmptyHint(
                message: 'No videos yet — upload an observation video',
              );
            }

            final items = videoList.take(6).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: r.h(12),
                crossAxisSpacing: r.w(12),
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final video = items[index];

                return Container(
                  padding: r.allPadding(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: r.borderRadius(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: r.w(56, tablet: 60, desktop: 64),
                        height: r.w(56, tablet: 60, desktop: 64),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.10),
                          borderRadius: r.borderRadius(8),
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          color: AppColors.primaryBlue,
                          size: r.icon(28, tablet: 30, desktop: 32),
                        ),
                      ),

                      r.gapW(14),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: r.sp(14, tablet: 15, desktop: 16),
                              ),
                            ),

                            r.gapH(2),

                            Text(
                              video.categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: r.sp(11, tablet: 12, desktop: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
