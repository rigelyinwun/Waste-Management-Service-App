import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String title;
  final String subtitle;
  final Timestamp time;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      time: data['time'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
