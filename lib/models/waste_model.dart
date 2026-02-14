import 'package:cloud_firestore/cloud_firestore.dart';

class WasteReportModel {
  final String id;
  final String userId;
  final String description;
  final String imageUrl;
  final GeoPoint location;
  final bool isPublic;
  final String status; // 'pending', 'collected'
  final Map<String, dynamic>? aiDetails; // Stores AI analysis
  final DateTime createdAt;
  final String? collectedBy;

  WasteReportModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.isPublic,
    this.status = 'pending',
    this.aiDetails,
    required this.createdAt,
    this.collectedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'isPublic': isPublic,
      'status': status,
      'aiDetails': aiDetails,
      'createdAt': createdAt,
      'collectedBy': collectedBy,
    };
  }

  factory WasteReportModel.fromMap(Map<String, dynamic> map) {
    return WasteReportModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'],
      isPublic: map['isPublic'] ?? false,
      status: map['status'] ?? 'pending',
      aiDetails: map['aiDetails'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      collectedBy: map['collectedBy'],
    );
  }
}
