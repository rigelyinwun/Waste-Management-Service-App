import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/report_submission_service.dart';

Future<void> testSubmitReport() async {
  print("TEST START");

  final service = ReportSubmissionService();

  try {
    // Fake image bytes (small dummy image)
    Uint8List fakeBytes = Uint8List.fromList(
      List.generate(100, (index) => index % 255),
    );

    await service.submitReport(
      userId: "debug_user_123",
      description: "Test illegal dumping of plastic waste",
      imageBytes: fakeBytes,
      location: GeoPoint(3.1390, 101.6869),
    );

    print("TEST SUCCESS ✅");
  } catch (e, stack) {
    print("TEST FAILED ❌");
    print(e);
    print(stack);
  }
}