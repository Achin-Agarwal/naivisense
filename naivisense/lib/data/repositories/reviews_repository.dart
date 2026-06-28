import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/review.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ReviewsRepository(ref.read(apiServiceProvider)),
);

class ReviewsRepository {
  final ApiService _api;
  ReviewsRepository(this._api);

  Future<List<ReviewModel>> getReviews({required String childId}) async {
    try {
      final res  = await _api.get('/reviews', params: {'childId': childId});
      final list = res.data as List<dynamic>;
      return list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ReviewModel> createReview(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/reviews', data: data);
      return ReviewModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ReviewModel> updateReview(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/reviews/$id', data: data);
      return ReviewModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
