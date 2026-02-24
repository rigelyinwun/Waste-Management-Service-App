import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/image_service.dart';
import '../services/ai_service.dart';
import '../services/company_matching_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class ReportSubmissionService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ReportService _reportService = ReportService();
  final ImageService _imageService = ImageService();
  final AIService _aiService = AIService();
  final CompanyMatchingService _matchingService =
      CompanyMatchingService();

  Future<String> uploadImageBytes(Uint8List bytes, String reportId) async {
    final ref = _storage.ref().child('reports/$reportId.jpg');

    await ref.putData(bytes);

    return await ref.getDownloadURL();
  }

  Future<void> submitReport({
    required String userId,
    required String description,
    required Uint8List imageBytes,
    required GeoPoint location,
    required String locationName,
    bool isPublic = false,
  }) async {
    final reportId =
        FirebaseFirestore.instance.collection('reports').doc().id;

    /// 1️⃣ Upload image
    final base64Image = base64Encode(imageBytes);

    /// 2️⃣ Create initial report
    final report = Report(
      reportId: reportId,
      userId: userId,
      imageUrl: base64Image,
      description: description,
      location: location,
      locationName: locationName,
      status: "analyzing",
      aiAnalysis: null,
      matchedCompanyId: null,
      createdAt: Timestamp.now(),
      isPublic: isPublic,
    );

    await _reportService.createReport(report);

    /// 3️⃣ Call AI
    final aiResult = await _aiService.analyzeWaste(description: description);

    /// 4️⃣ Update AI result
    await _reportService.updateAIAnalysis(
        reportId, aiResult.toMap());

    /// 5️⃣ Match company
    final matchedCompanyId =
        await _matchingService.findMatchingCompany(
            aiResult.category);

    if (matchedCompanyId != null) {
      await _reportService.matchCompany(
          reportId, matchedCompanyId);
    } else {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .update({'status': 'no_company_found'});
    }
  }
}