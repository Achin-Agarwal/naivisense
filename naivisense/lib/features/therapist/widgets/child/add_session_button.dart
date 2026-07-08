import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/features/therapist/providers/therapist_provider.dart';
import 'package:naivisense/features/therapist/screens/create_session_screen.dart';

class AddSessionButton extends ConsumerWidget {
  final ChildModel child;

  const AddSessionButton({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    return SizedBox(
      width: double.infinity,
      height: responsive.h(48, tablet: 52, desktop: 56),
      child: ElevatedButton.icon(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateSessionScreen(preselectedChild: child),
            ),
          );

          if (created == true && context.mounted) {
            ref.invalidate(therapistChildSessionsProvider(child.id));
            ref.invalidate(therapistChildNextSessionProvider(child.id));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session scheduled successfully')),
            );
          }
        },
        icon: Icon(
          Icons.add_circle_outline,
          size: responsive.icon(20, tablet: 22, desktop: 24),
        ),
        label: Text(
          'Schedule New Session',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: responsive.sp(14, tablet: 15, desktop: 16),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: responsive.borderRadius(14, tablet: 16, desktop: 18),
          ),
        ),
      ),
    );
  }
}
