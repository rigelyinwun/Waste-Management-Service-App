import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String role; // 'user' or 'admin'
  final String? photoUrl;
  final GeoPoint? location;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    this.photoUrl,
    this.location,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'photoUrl': photoUrl,
      'location': location,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'user',
      photoUrl: map['photoUrl'],
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
