import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_analysis_model.dart';

class Report {
  final String reportId;
  final String userId;
  final String imageUrl;
  final String description;
  final GeoPoint location;
  final String status;
  final AIAnalysis? aiAnalysis;
  final String? matchedCompanyId;
  final Timestamp createdAt;

  Report({
    required this.reportId,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.status,
    this.aiAnalysis,
    this.matchedCompanyId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'location': location,
      'status': status,
      'aiAnalysis': aiAnalysis?.toMap(),
      'matchedCompanyId': matchedCompanyId,
      'createdAt': createdAt,
    };
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Report(
      reportId: doc.id,
      userId: data['userId'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      location: data['location'],
      status: data['status'],
      aiAnalysis: data['aiAnalysis'] != null
          ? AIAnalysis.fromMap(data['aiAnalysis'])
          : null,
      matchedCompanyId: data['matchedCompanyId'],
      createdAt: data['createdAt'],
    );
  }
}