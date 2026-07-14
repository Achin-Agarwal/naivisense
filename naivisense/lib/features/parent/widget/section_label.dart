import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ui.sp(16, tablet: 17, desktop: 18),
      ),
    );
  }
}
