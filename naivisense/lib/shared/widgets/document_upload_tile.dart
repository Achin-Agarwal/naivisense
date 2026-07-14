import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class DocumentUploadTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Uint8List? bytes;
  final VoidCallback onTap;

  const DocumentUploadTile({
    super.key,
    required this.label,
    required this.icon,
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: bytes != null
              ? r.value(mobile: 140, tablet: 150, desktop: 170)
              : r.value(mobile: 70, tablet: 80, desktop: 90),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(
              r.radius(12, tablet: 13, desktop: 14),
            ),
            border: Border.all(
              color: bytes != null ? AppColors.primaryBlue : AppColors.divider,
              width: bytes != null ? 1.5 : 1,
            ),
          ),
          child: bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    r.radius(11, tablet: 12, desktop: 13),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(bytes!, fit: BoxFit.cover),

                      Positioned(
                        top: r.h(8),
                        right: r.w(8),
                        child: Container(
                          padding: EdgeInsets.all(
                            r.value(mobile: 5, tablet: 6, desktop: 7),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(r.radius(8)),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: r.icon(15, tablet: 16, desktop: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.w(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: r.icon(22, tablet: 24, desktop: 28),
                          color: AppColors.textSecondary,
                        ),

                        SizedBox(width: r.w(10, tablet: 12, desktop: 14)),

                        Flexible(
                          child: Text(
                            'Tap to upload $label',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: r.sp(13, tablet: 14, desktop: 15),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
