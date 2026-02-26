import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String role;
  final String email;

  // user fields
  final String? username;

  // company fields
  final String? companyName;
  final String? companySSM;
  final String? phoneNumber;
  final List<String>? wasteCategories;
  final List<String>? serviceAreas;

  AppUser({
    required this.uid,
    required this.role,
    required this.email,
    this.username,
    this.companyName,
    this.companySSM,
    this.phoneNumber,
    this.wasteCategories,
    this.serviceAreas,
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'email': email,
      'username': username,
      'companyName': companyName,
      'companySSM': companySSM,
      'phoneNumber': phoneNumber,
      'wasteCategories': wasteCategories,
      'serviceAreas': serviceAreas,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      role: map['role'],
      email: map['email'],
      username: map['username'],
      companyName: map['companyName'],
      companySSM: map['companySSM'],
      phoneNumber: map['phoneNumber'],
      wasteCategories:
          map['wasteCategories'] != null
              ? List<String>.from(map['wasteCategories'])
              : null,
      serviceAreas:
          map['serviceAreas'] != null
              ? List<String>.from(map['serviceAreas'])
              : null,
    );
  }
}