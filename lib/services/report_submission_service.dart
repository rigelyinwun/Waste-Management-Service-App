import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/ai_service.dart';
import '../services/company_matching_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class ReportSubmissionService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ReportService _reportService = ReportService();
  final AIService _aiService = AIService();
  final CompanyMatchingService _matchingService =
      CompanyMatchingService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

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

    /// 1️⃣ Prepare image (base64 for now)
    final base64Image = base64Encode(imageBytes);

    /// 2️⃣ Call AI Analysis first
    final aiResult = await _aiService.analyzeWaste(description: description);

    /// 3️⃣ Match company based on AI category
    final matchedCompanyId =
        await _matchingService.findMatchingCompany(aiResult.category);

    String? matchedCompanyName;
    if (matchedCompanyId != null) {
      final companyProfile = await _userService.fetchUserProfile(matchedCompanyId);
      matchedCompanyName = companyProfile?.companyName;
    }

    /// 4️⃣ Determine initial status
    final String initialStatus = matchedCompanyId != null ? "matched" : "no_company_found";

    /// 5️⃣ Send notification if matched
    if (matchedCompanyId != null) {
      await _notificationService.sendNotification(NotificationModel(
        id: '', // Firestore will generate this
        recipientId: userId,
        title: "Company Matched!",
        subtitle:
            "A company '${matchedCompanyName ?? 'Unknown'}' has been found for your waste report.",
        type: "company_match",
        relatedId: reportId,
        time: Timestamp.now(),
      ));
    }

    /// 6️⃣ Create complete report
    final report = Report(
      reportId: reportId,
      userId: userId,
      imageUrl: base64Image,
      description: description,
      location: location,
      locationName: locationName,
      status: initialStatus,
      aiAnalysis: aiResult,
      matchedCompanyId: matchedCompanyId,
      matchedCompanyName: matchedCompanyName,
      createdAt: Timestamp.now(),
      isPublic: isPublic,
    );

    /// 7️⃣ Save everything to Firestore in one go
    await _reportService.createReport(report);
  }
}