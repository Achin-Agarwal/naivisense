import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:naivisense/data/models/therapist_overview.dart';

import '../../../core/utils/responsive.dart';
import '../../../../shared/widgets/state_widgets.dart' as sw;
import 'therapist_admin_card.dart';

class TherapistsSection extends StatelessWidget {
  final AsyncValue<List<TherapistOverview>> therapists;

  const TherapistsSection({super.key, required this.therapists});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Therapists',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: r.sp(24, tablet: 26, desktop: 28),
          ),
        ),

        r.gapH(12, tablet: 16, desktop: 20),

        therapists.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No therapists registered yet',
                icon: Icons.medical_services_outlined,
              );
            }

            return MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: r.isDesktop
                  ? 3
                  : r.isTablet
                  ? 2
                  : 1,

              mainAxisSpacing: r.h(18),
              crossAxisSpacing: r.w(18),

              itemCount: list.length,

              itemBuilder: (context, index) {
                return TherapistAdminCard(therapist: list[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
