import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/review.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

import 'empty_message.dart';
import 'review_row.dart';

class ReviewsSection extends ConsumerWidget {
  final AsyncValue<List<ReviewModel>> reviews;

  const ReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    return ProfileCard(
      title: 'Reviews',
      icon: Icons.summarize_outlined,
      child: reviews.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),

        error: (_, __) => const EmptyMessage(message: 'Could not load reviews'),

        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(message: 'No reviews yet');
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => responsive.gapH(12),
            itemBuilder: (_, index) => ReviewRow(review: list[index]),
          );
        },
      ),
    );
  }
}
