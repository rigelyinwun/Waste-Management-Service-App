import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String companyId;
  final String reportId;
  final int rating; // 1–5
  final String comment;
  final Timestamp createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    required this.companyId,
    required this.reportId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'userId': userId,
      'companyId': companyId,
      'reportId': reportId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedbackId'],
      userId: map['userId'],
      companyId: map['companyId'],
      reportId: map['reportId'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: map['createdAt'],
    );
  }
}