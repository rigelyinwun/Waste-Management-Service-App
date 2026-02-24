import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "notifications";

  Future<void> sendNotification(NotificationModel notification) async {
    await _firestore
        .collection(_collection)
        .add(notification.toMap());
  }

  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('recipientId', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
