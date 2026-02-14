import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    final doc =
        await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update(updates);
  }
}