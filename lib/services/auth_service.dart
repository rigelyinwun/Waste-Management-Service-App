import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google (For Users)
  Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    UserCredential userCredential =
        await _auth.signInWithProvider(googleProvider);

    if (userCredential.user != null) {
      await _saveUserToFirestore(userCredential.user!);
    }

    return userCredential;
  } catch (e) {
    print("Error signing in with Google: $e");
    return null;
  }
  }

  // Register Admin (Email/Password)
  Future<UserCredential?> registerAdmin(String email, String password, Map<String, dynamic> companyData) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _saveAdminToFirestore(userCredential.user!, companyData);
      }

      return userCredential;
    } catch (e) {
       print("Error registering admin: $e");
       return null;
    }
  }

  // Login Admin (Email/Password)
  Future<UserCredential?> loginAdmin(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error logging in admin: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
  await _auth.signOut();
}

  // Save User to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: user.displayName ?? 'User',
        role: 'user',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await userRef.set(newUser.toMap());
    }
  }
  
  // Save Admin to Firestore
  Future<void> _saveAdminToFirestore(User user, Map<String, dynamic> companyData) async {
     // Save to 'companies' or 'admins' collection. 
     // Using 'users' collection to store basic info and 'companies' for details is also an option,
     // but for separation let's store basics in users with role 'admin' and details in companies.
     
     final userRef = _firestore.collection('users').doc(user.uid);
     final companyRef = _firestore.collection('companies').doc(user.uid);

     final newAdmin = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: companyData['companyName'] ?? 'Admin',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      
      await userRef.set(newAdmin.toMap());
      
      // Add uid to companyData before saving
      companyData['uid'] = user.uid;
      await companyRef.set(companyData);
  }

  // Get User Role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'] as String?;
      }
    } catch (e) {
      print("Error getting user role: $e");
    }
    return null;
  }
}
