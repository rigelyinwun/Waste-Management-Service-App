import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:smart_waste/services/feedback_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FeedbackService feedbackService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();

    // inject fake firestore directly
    feedbackService =
        FeedbackService(firestore: fakeFirestore);
  });

  test("Create feedback should store data", () async {
    await feedbackService.createFeedback(
      userId: "user1",
      companyId: "company1",
      reportId: "report1",
      rating: 5,
      comment: "Good service",
    );

    final snapshot =
        await fakeFirestore.collection('feedback').get();

    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first['rating'], 5);
  });
}