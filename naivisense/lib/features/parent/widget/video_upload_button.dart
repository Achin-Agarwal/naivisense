import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/parent/providers/parent_provider.dart';


class VideoUploadButton extends ConsumerStatefulWidget {
  final String childId;

  const VideoUploadButton({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<VideoUploadButton> createState() =>
      _VideoUploadButtonState();
}

class _VideoUploadButtonState
    extends ConsumerState<VideoUploadButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _upload() async {
    final r = Responsive(context);
    final titleController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogResponsive = Responsive(dialogContext);
        final viewInsets = MediaQuery.viewInsetsOf(dialogContext);

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogResponsive.formWidth,
              ),
              child: AlertDialog(
                title: Text(
                  'Upload Observation Video',
                  style: TextStyle(
                    fontSize: dialogResponsive.sp(
                      18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Video title',
                      hintText:
                          'e.g. Morning activity observation',
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, true),
                    child: const Text('Choose Video'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true ||
        titleController.text.trim().isEmpty) {
      titleController.dispose();
      return;
    }

    final pickedVideo = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo == null) {
      titleController.dispose();
      return;
    }

    final success = await ref
        .read(videoUploadProvider.notifier)
        .upload(
          childId: widget.childId,
          title: titleController.text.trim(),
          filePath: pickedVideo.path,
          mimeType: 'video/mp4',
        );

    titleController.dispose();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Video uploaded successfully'
              : 'Upload failed',
        ),
        backgroundColor: success
            ? AppColors.mintGreen
            : AppColors.softCoral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final uploadState = ref.watch(videoUploadProvider);

    return TextButton.icon(
      onPressed: uploadState.loading ? null : _upload,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
      ),
      icon: uploadState.loading
          ? SizedBox(
              width: r.icon(
                18,
                tablet: 20,
                desktop: 22,
              ),
              height: r.icon(
                18,
                tablet: 20,
                desktop: 22,
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Icon(
              Icons.upload_outlined,
              size: r.icon(
                22,
                tablet: 24,
                desktop: 26,
              ),
            ),
      label: Text(
        'Upload',
        style: TextStyle(
          fontSize: r.sp(
            14,
            tablet: 15,
            desktop: 16,
          ),
        ),
      ),
    );
  }
}