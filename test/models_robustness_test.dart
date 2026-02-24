import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_waste/models/report_model.dart';
import 'package:smart_waste/models/ai_analysis_model.dart';

void main() {
  group('Model Robustness Tests', () {
    test('AIAnalysis.fromMap handles missing/null fields', () {
      final partialMap = {
        'category': 'Plastic',
        // estimatedWeightKg missing
        'recommendedTransport': 'Motorcycle',
        // estimatedCost null
        'estimatedCost': null,
        'isRecyclable': true,
      };

      final analysis = AIAnalysis.fromMap(partialMap);

      expect(analysis.category, 'Plastic');
      expect(analysis.estimatedWeightKg, 0.0);
      expect(analysis.recommendedTransport, 'Motorcycle');
      expect(analysis.estimatedCost, 0.0);
      expect(analysis.hazardLevel, 'Low'); // Default
      expect(analysis.isRecyclable, true);
    });

    test('AIAnalysis.fromMap handles missing isRecyclable with default false', () {
      final analysis = AIAnalysis.fromMap({});
      expect(analysis.isRecyclable, false);
    });

    test('Report constructor handles partial data safely', () {
      final Map<String, dynamic> data = {
        'userId': 'user123',
        'description': 'Test report',
        'location': null,
        'status': null,
      };

      final report = Report(
        reportId: 'doc_id',
        userId: data['userId'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        description: data['description'] ?? '',
        location: (data['location'] as GeoPoint?) ?? const GeoPoint(0, 0),
        locationName: data['locationName'] ?? '',
        status: data['status'] ?? 'pending',
        createdAt: Timestamp.now(),
      );

      expect(report.reportId, 'doc_id');
      expect(report.imageUrl, '');
      expect(report.location.latitude, 0.0);
      expect(report.status, 'pending');
    });
  });
}
