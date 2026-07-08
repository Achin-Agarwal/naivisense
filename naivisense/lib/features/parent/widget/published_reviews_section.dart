import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/review.dart';
import 'package:naivisense/shared/widgets/app_card.dart';


class PublishedReviewsSection extends StatelessWidget {
  final AsyncValue<List<ReviewModel>> reviews;

  const PublishedReviewsSection({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return reviews.when(
      loading: () => const SizedBox.shrink(),

      error: (_, __) => const SizedBox.shrink(),

      data: (reviewList) {
        final publishedReviews =
            reviewList.where((review) => review.isPublished).toList();

        if (publishedReviews.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Reviews',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: r.sp(
                        17,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
              ),

              r.gapH(16),

              ...publishedReviews.take(3).map(
                (review) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: r.h(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.typeLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: r.sp(
                                  12,
                                  tablet: 13,
                                  desktop: 14,
                                ),
                              ),
                            ),
                          ),

                          Text(
                            '${review.periodStart.day}/${review.periodStart.month}/${review.periodStart.year}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: r.sp(
                                11,
                                tablet: 12,
                                desktop: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      r.gapH(4),

                      Text(
                        review.textObservations,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: r.sp(
                            12,
                            tablet: 13,
                            desktop: 14,
                          ),
                        ),
                      ),

                      if (review.adminNotes != null &&
                          review.adminNotes!.isNotEmpty) ...[
                        r.gapH(4),

                        Text(
                          'Note: ${review.adminNotes}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontStyle: FontStyle.italic,
                            fontSize: r.sp(
                              11,
                              tablet: 12,
                              desktop: 13,
                            ),
                          ),
                        ),
                      ],

                      Divider(
                        height: r.h(24),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}