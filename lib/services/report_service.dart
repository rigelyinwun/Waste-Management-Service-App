import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "reports";

  Future<void> createReport(Report report) async {
    await _firestore
        .collection(_collection)
        .doc(report.reportId)
        .set(report.toMap());
  }

  Future<void> updateAIAnalysis(
      String reportId, Map<String, dynamic> aiData) async {
    await _firestore.collection(_collection).doc(reportId).update({
      'aiAnalysis': aiData,
    });
  }

  Future<void> matchCompany(
      String reportId, String companyId) async {
    await _firestore.collection(_collection).doc(reportId).update({
      'matchedCompanyId': companyId,
      'status': 'matched'
    });
  }

  Stream<List<Report>> getReportsByUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }

  Stream<List<Report>> getUnmatchedReports() {
    return _firestore
        .collection(_collection)
        .where('matchedCompanyId', isNull: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }
}