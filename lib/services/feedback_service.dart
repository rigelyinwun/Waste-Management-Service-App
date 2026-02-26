import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore;

  // Proper dependency injection
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create feedback
  Future<void> createFeedback({
    required String userId,
    required String companyId,
    required String reportId,
    required int rating,
    required String comment,
  }) async {
    final feedbackId =
        _firestore.collection('feedback').doc().id;

    final feedback = FeedbackModel(
      feedbackId: feedbackId,
      userId: userId,
      companyId: companyId,
      reportId: reportId,
      rating: rating,
      comment: comment,
      createdAt: Timestamp.now(),
    );

    await _firestore
        .collection('feedback')
        .doc(feedbackId)
        .set(feedback.toMap());
  }

  /// Fetch feedback for a company
  Future<List<FeedbackModel>> getCompanyFeedback(
      String companyId) async {
    final snapshot = await _firestore
        .collection('feedback')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FeedbackModel.fromMap(doc.data()))
        .toList();
  }

  /// Fetch feedback by user
  Future<List<FeedbackModel>> getUserFeedback(
      String userId) async {
    final snapshot = await _firestore
        .collection('feedback')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FeedbackModel.fromMap(doc.data()))
        .toList();
  }
}