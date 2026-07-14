import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/reports_repository.dart';

class ReportParams {
  final String childId;
  final DateTime from;
  final DateTime to;

  const ReportParams({
    required this.childId,
    required this.from,
    required this.to,
  });

  @override
  bool operator ==(Object other) =>
      other is ReportParams &&
      other.childId == childId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(childId, from, to);
}

final progressReportProvider =
    FutureProvider.family<ProgressReport, ReportParams>(
      (ref, params) => ref
          .read(reportsRepositoryProvider)
          .getProgress(
            childId: params.childId,
            from: params.from,
            to: params.to,
          ),
    );
