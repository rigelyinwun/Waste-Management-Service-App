import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/waste_model.dart';
import 'package:uuid/uuid.dart';

class WasteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Collection Reference
  CollectionReference get _reportsRef => _firestore.collection('waste_reports');

  // Create New Report
  Future<void> createReport(WasteReportModel report, File? imageFile) async {
    String imageUrl = '';

    if (imageFile != null) {
      // Upload Image to Firebase Storage
      try {
        final ref = _storage.ref().child('waste_images/${report.id}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print("Error uploading image: $e");
        // Proceed without image or handle error
      }
    }

    // Update report with image URL
    final newReport = WasteReportModel(
      id: report.id,
      userId: report.userId,
      description: report.description,
      imageUrl: imageUrl,
      location: report.location,
      isPublic: report.isPublic,
      status: report.status,
      aiDetails: report.aiDetails,
      createdAt: report.createdAt,
      collectedBy: report.collectedBy,
    );

    await _reportsRef.doc(report.id).set(newReport.toMap());
  }

  // Get Nearby Reports (Mocked 'nearby' for now - returns all pending public reports)
  Stream<List<WasteReportModel>> getNearbyReports() {
    return _reportsRef
        .where('status', isEqualTo: 'pending')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WasteReportModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get User's Reports
  Stream<List<WasteReportModel>> getUserReports(String userId) {
    return _reportsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WasteReportModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
