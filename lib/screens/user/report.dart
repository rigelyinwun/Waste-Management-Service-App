import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/report_submission_service.dart';
import '../../services/image_service.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_test.dart';

class ReportTestScreen extends StatefulWidget {
  @override
  _ReportTestScreenState createState() => _ReportTestScreenState();
}

class _ReportTestScreenState extends State<ReportTestScreen> {
  final _descriptionController = TextEditingController();
  final ImageService _imageService = ImageService();
  final ReportSubmissionService _submissionService =
      ReportSubmissionService();
  final ReportService _reportService = ReportService();

  Uint8List? _imageBytes;
  bool _isSubmitting = false;

  void pickImage() async {
    final bytes = await _imageService.pickImageBytes();
    setState(() => _imageBytes = bytes);
  }

  void submitReport() async {
    if (_imageBytes == null || _descriptionController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not logged in")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _submissionService.submitReport(
        userId: user.uid,
        description: _descriptionController.text,
        imageBytes: _imageBytes!,
        location: GeoPoint(3.1390, 101.6869),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report submitted!")),
      );

      _descriptionController.clear();
      setState(() => _imageBytes = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Report Test (Create + AI + Display)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 10),

            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 150)
                : Text("No image selected"),

            ElevatedButton(
              onPressed: pickImage,
              child: Text("Pick Image"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isSubmitting ? null : submitReport,
              child: _isSubmitting
                  ? CircularProgressIndicator()
                  : Text("Submit Report"),
            ),
            ElevatedButton(
              onPressed: () async {
                await testSubmitReport();
              },
              child: Text("Run Submission Test"),
            ),

            Divider(),

            Text(
              "Submitted Reports",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            StreamBuilder<List<Report>>(
              stream: _reportService.getReportsByUser(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final reports = snapshot.data!;

                if (reports.isEmpty) {
                  return Text("No reports yet.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(report.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Status: ${report.status}"),
                            if (report.aiAnalysis != null) ...[
                              Text(
                                  "Category: ${report.aiAnalysis!.category}"),
                              Text(
                                  "Weight: ${report.aiAnalysis!.estimatedWeightKg} kg"),
                              Text(
                                  "Transport: ${report.aiAnalysis!.recommendedTransport}"),
                              Text(
                                  "Cost: RM ${report.aiAnalysis!.estimatedCost}"),
                              Text(
                                  "Hazard: ${report.aiAnalysis!.hazardLevel}"),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}