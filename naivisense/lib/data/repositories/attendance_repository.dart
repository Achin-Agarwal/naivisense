import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/attendance_record.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.read(apiServiceProvider)),
);

class AttendanceRepository {
  final ApiService _api;
  AttendanceRepository(this._api);

  Future<List<AttendanceRecord>> getAttendance({required String childId}) async {
    try {
      final res  = await _api.get('/attendance', params: {'childId': childId});
      final list = res.data as List<dynamic>;
      return list
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AttendanceRecord> markAttendance(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/attendance', data: data);
      return AttendanceRecord.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
