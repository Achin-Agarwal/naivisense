import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/video_item.dart';
import 'empty_message.dart';
import 'video_row.dart';

class VideosSection extends StatelessWidget {
  const VideosSection({super.key, required this.videos});

  final AsyncValue<List<VideoItemModel>> videos;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return ProfileCard(
      title: "Videos",
      icon: Icons.videocam_outlined,
      child: videos.when(
        loading: () => SizedBox(
          height: r.h(14,tablet: 12, desktop: 10),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),

        error: (_, __) => const EmptyMessage(message: "Could not load videos"),

        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(message: "No videos uploaded yet");
          }

          final crossAxisCount = r.isDesktop
              ? 3
              : r.isTablet
              ? 2
              : 1;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: r.isDesktop
                  ? 2.3
                  : r.isTablet
                  ? 2.0
                  : 2.6,
            ),
            itemBuilder: (_, index) {
              return VideoRow(video: list[index]);
            },
          );
        },
      ),
    );
  }
}
