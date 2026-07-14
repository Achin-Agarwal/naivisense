import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:naivisense/core/utils/web_video_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/parent/providers/parent_provider.dart';

class VideoUploadButton extends ConsumerStatefulWidget {
  final String childId;

  const VideoUploadButton({super.key, required this.childId});

  @override
  ConsumerState<VideoUploadButton> createState() => _VideoUploadButtonState();
}

class _VideoUploadButtonState extends ConsumerState<VideoUploadButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _upload() async {
    final titleController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final r = Responsive(dialogContext);
        final viewInsets = MediaQuery.viewInsetsOf(dialogContext);

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.formWidth),
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    title: Text(
                      'Upload Observation Video',
                      style: TextStyle(
                        fontSize: r.sp(18, tablet: 20, desktop: 22),
                      ),
                    ),

                    content: SingleChildScrollView(
                      child: TextField(
                        controller: titleController,
                        onChanged: (_) {
                          setDialogState(() {});
                        },
                        decoration: const InputDecoration(
                          labelText: 'Video title',
                          hintText: 'e.g. Morning activity observation',
                        ),
                      ),
                    ),

                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),

                      ElevatedButton(
                        onPressed: titleController.text.trim().isEmpty
                            ? null
                            : () => Navigator.pop(dialogContext, true),
                        child: const Text('Choose Video'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || titleController.text.trim().isEmpty) {
      titleController.dispose();
      return;
    }

    String? filePath;
    Uint8List? fileBytes;
    String? fileName;

    try {
      // ---------------- WEB ----------------
      if (kIsWeb) {
        final result = await pickWebVideo();

        if (result == null) {
          titleController.dispose();
          return;
        }

        fileBytes = result.bytes;
        fileName = result.name;
      }
      // -------------- MOBILE --------------
      else if (Platform.isAndroid || Platform.isIOS) {
        final picked = await _picker.pickVideo(source: ImageSource.gallery);

        if (picked == null) {
          titleController.dispose();
          return;
        }

        filePath = picked.path;
        fileName = picked.name;
      }
      // -------------- DESKTOP -------------
      else {
        final result = await FilePicker.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) {
          titleController.dispose();
          return;
        }

        final file = result.files.single;

        filePath = file.path;
        fileName = file.name;
      }
    } catch (e) {
      titleController.dispose();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to select video.\n$e'),
            backgroundColor: AppColors.softCoral,
          ),
        );
      }

      return;
    }

    final success = await ref
        .read(videoUploadProvider.notifier)
        .upload(
          childId: widget.childId,
          title: titleController.text.trim(),
          filePath: filePath,
          fileBytes: fileBytes,
          fileName: fileName,
          mimeType: 'video/mp4',
        );
    titleController.dispose();
    print('Video upload result: $success');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Video uploaded successfully' : 'Upload failed',
        ),
        backgroundColor: success ? AppColors.mintGreen : AppColors.softCoral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final uploadState = ref.watch(videoUploadProvider);

    return TextButton.icon(
      onPressed: uploadState.loading ? null : _upload,

      style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),

      icon: uploadState.loading
          ? SizedBox(
              width: r.icon(18, tablet: 20, desktop: 22),
              height: r.icon(18, tablet: 20, desktop: 22),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.upload_outlined,
              size: r.icon(22, tablet: 24, desktop: 26),
            ),

      label: Text(
        'Upload',
        style: TextStyle(fontSize: r.sp(14, tablet: 15, desktop: 16)),
      ),
    );
  }
}
