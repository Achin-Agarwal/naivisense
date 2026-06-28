import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/video_item.dart';

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
      if (category != null) params['category'] = category;
      final res  = await _api.get('/videos', params: params);
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
    required String filePath,
    required String mimeType,
    String visibility = 'internal',
    String? description,
    String? linkedConcernId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'child_id':   childId,
        'title':      title,
        'category':   category,
        'visibility': visibility,
        'description':       ?description,
        'linked_concern_id': ?linkedConcernId,
        'video': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });
      final res = await _api.postForm('/videos', formData);
      return VideoItemModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<VideoItemModel> updateVideo(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/videos/$id', data: data);
      return VideoItemModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
