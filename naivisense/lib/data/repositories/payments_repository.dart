import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/payment.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepository(ref.read(apiServiceProvider)),
);

class PaymentsRepository {
  final ApiService _api;
  PaymentsRepository(this._api);

  Future<List<PaymentModel>> getPayments({String? childId}) async {
    try {
      final res  = await _api.get('/payments', params: {
        'child_id': ?childId,
      });
      final list = res.data as List<dynamic>;
      return list.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<PaymentModel> createPayment(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/payments', data: data);
      return PaymentModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<PaymentModel> updateStatus(String id, String status, {String? razorpayPaymentId}) async {
    try {
      final res = await _api.patch('/payments/$id/status', data: {
        'status': status,
        'razorpay_payment_id': ?razorpayPaymentId,
      });
      return PaymentModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final res = await _api.get('/payments/summary');
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
