import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/responsive.dart';

class ScoreTile extends StatelessWidget {
  final String title;
  final int score;
  final Color color;

  const ScoreTile({
    super.key,
    required this.title,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final progress = (score / 10).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(r.w(14, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: r.sp(12, tablet: 13, desktop: 14),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),

          r.gapH(12),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.radius(8)),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: r.h(6, tablet: 7, desktop: 8),
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),

              r.gapW(10),

              Text(
                '$score/10',
                style: TextStyle(
                  fontSize: r.sp(12, tablet: 13, desktop: 14),
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
