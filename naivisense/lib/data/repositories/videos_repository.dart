import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/video_item.dart';
import 'package:naivisense/data/services/api_service.dart';
import 'package:naivisense/data/services/error_handler_service.dart';

final videosRepositoryProvider = Provider<VideosRepository>(
  (ref) => VideosRepository(ref.read(apiServiceProvider)),
);

class VideosRepository {
  final ApiService _api;

  VideosRepository(this._api);

  Future<List<VideoItemModel>> getVideos({
    required String childId,
    String? category,
  }) async {
    try {
      final params = <String, dynamic>{'childId': childId};

      if (category != null) {
        params['category'] = category;
      }

      final res = await _api.get('/videos', params: params);

      final list = res.data as List<dynamic>;

      return list
          .map((e) => VideoItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<VideoItemModel> uploadVideo({
    required String childId,
    required String title,
    required String category,

    /// Mobile/Desktop
    String? filePath,

    /// Web
    Uint8List? fileBytes,
    String? fileName,

    required String mimeType,

    String visibility = 'internal',
    String? description,
    String? linkedConcernId,
  }) async {
    try {
      MultipartFile videoFile;
      if (kIsWeb) {
        if (fileBytes == null) {
          throw Exception('Video bytes are missing.');
        }

        videoFile = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName ?? 'video.mp4',
          contentType: DioMediaType.parse(mimeType),
        );
      } else {
        if (filePath == null) {
          throw Exception('Video path is missing.');
        }

        videoFile = await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('/').last,
          contentType: DioMediaType.parse(mimeType),
        );
      }

      final formData = FormData.fromMap({
        'child_id': childId,
        'title': title,
        'category': category,
        'visibility': visibility,

        if (description != null && description.isNotEmpty)
          'description': description,

        if (linkedConcernId != null && linkedConcernId.isNotEmpty)
          'linked_concern_id': linkedConcernId,

        'video': videoFile,
      });
      print(
        'Uploading video for childId: $childId, title: $title, category: $category, visibility: $visibility',
      );

      final res = await _api.postForm('/videos', formData);
      print(res.data);

      return VideoItemModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<VideoItemModel> updateVideo(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _api.patch('/videos/$id', data: data);

      return VideoItemModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
