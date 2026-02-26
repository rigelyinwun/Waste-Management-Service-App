// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/report_submission_service.dart';
import '../../services/image_service.dart';
import '../../models/report_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();
  final ImageService _imageService = ImageService();
  final ReportSubmissionService _submissionService =
      ReportSubmissionService();

  Uint8List? _imageBytes;
  bool _isLoading = false;
  int currentStep = 0;
  bool isPublic = true;
  Report? _submittedReport;

  Future<void> _pickImage() async {
    final bytes = await _imageService.pickImageBytes();
    if (bytes != null) {
      setState(() {
        _imageBytes = bytes;
        currentStep = 0; // Ensure we are on the form page
      });
    }
  }

  Future<void> _submitReport() async {
    final description = _descriptionController.text.trim();
    final locationName = _locationController.text.trim();
    final user = _authService.currentUser;

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a photo")),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a description")),
      );
      return;
    }

    if (locationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a location")),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the submission service which handles image upload (base64 for now), AI, and Matching
      await _submissionService.submitReport(
        userId: user.uid,
        description: description,
        imageBytes: _imageBytes!,
        location: const GeoPoint(3.1390, 101.6869), // Mock location (Cyberjaya)
        locationName: locationName,
        isPublic: isPublic,
      );

      // Fetch the latest report to show results
      final reports = await _reportService.getReportsByUser(user.uid).first;
      if (reports.isNotEmpty) {
        setState(() {
          _submittedReport = reports.first;
          currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit report: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep == 0) return _buildInitialForm();
    if (currentStep == 1) return _buildScanningView();
    return _buildSubmissionResult();
  }

  Widget _buildInitialForm() {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: _buildAppBar("Report Waste", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload Photos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color(0xFFAED6BE),
                    borderRadius: BorderRadius.circular(20)),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(Icons.image_outlined,
                                size: 50, color: Colors.black38),
                            Text("Click to upload",
                                style: TextStyle(color: Colors.black38)),
                          ]),
              ),
            ),
            const SizedBox(height: 25),
            _customLabel("Description"),
            _customField("Add condition, quantity, urgency...",
                _descriptionController),
            const SizedBox(height: 20),
            _customLabel("Location"),
            _customField("Select Location", _locationController, icon: Icons.location_on),
            const SizedBox(height: 25),
            _buildPublicToggle(),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _primaryButton("Submit Report", _submitReport),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    // This view is currently triggered by the pickImage, but we display the result in the initial form
    // Keeping it simple for now as per user instruction to combine.
    return _buildInitialForm();
  }

  Widget _buildSubmissionResult() {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: _buildAppBar("Report Waste"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(children: [
              Icon(Icons.check, size: 28, color: Colors.green),
              SizedBox(width: 10),
              Text("Your report is submitted!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ]),
            if (_submittedReport?.matchedCompanyId != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "We found a matched company: ${_submittedReport?.matchedCompanyName ?? 'Processing...'}",
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_submittedReport != null && _submittedReport!.matchedCompanyId == null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withAlpha(100)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "No direct company match found. Your report is now public for collection.",
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 15),
            if (_imageBytes != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(_imageBytes!,
                      height: 180, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 20),
            _resultTile(
                "Category", _submittedReport?.aiAnalysis?.category ?? "Pending",
                () => _showCategorySheet()),
            _resultTile("Date", "Today", () => _showTimelineSheet()),
            _resultTile("Location", _submittedReport?.locationName ?? "Unknown", () => _showLocationSheet()),
            _resultTile(
                "Weight",
                "Approx. ${_submittedReport?.aiAnalysis?.estimatedWeightKg ?? 0} kg",
                () {}),
            const SizedBox(height: 20),
            _buildResultDetailsBox(),
            const SizedBox(height: 30),
            _primaryButton(
                "Back to Form", () => setState(() => currentStep = 0)),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Category Details",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.category, color: Colors.white),
                title: Text(_submittedReport?.aiAnalysis?.category ?? "Pending",
                    style: const TextStyle(color: Colors.white))),
            Text(
                "Description: ${_submittedReport?.description ?? 'N/A'}",
                style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white24),
            Text(
                "Transport: ${_submittedReport?.aiAnalysis?.recommendedTransport ?? 'N/A'}",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title, {bool showBack = false}) => AppBar(
        backgroundColor: const Color(0xFF387664),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBack,
        leading: showBack ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)) : null,
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  Widget _customLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _customField(String hint, TextEditingController? controller,
          {IconData? icon}) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon:
              icon != null ? Icon(icon, color: const Color(0xFF387664)) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      );

  Widget _buildPublicToggle() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Allow Public Collection?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Switch(
                value: isPublic,
                activeThumbColor: const Color(0xFF387664),
                onChanged: (v) => setState(() => isPublic = v))
          ]);

  Widget _primaryButton(String text, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5E4E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: onTap,
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 18))));

  Widget _resultTile(String label, String value, VoidCallback onTap) =>
      ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing:
            Text("$value >", style: const TextStyle(color: Colors.black54)),
        onTap: onTap,
      );

  Widget _buildResultDetailsBox() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xFFCDE2D6),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Result Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(
                "Hazard Level: ${_submittedReport?.aiAnalysis?.hazardLevel ?? 'N/A'}\nEstimated Cost: RM ${_submittedReport?.aiAnalysis?.estimatedCost ?? 0}",
                style: const TextStyle(height: 1.5)),
            if (_submittedReport?.matchedCompanyName != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Matched: ${_submittedReport?.matchedCompanyName}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF2E5E4E)),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  void _showTimelineSheet() {}
  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Location Details",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _sheetItem("Reported Location", _submittedReport?.locationName ?? "Unknown"),
            _sheetItem("Geolocation", "Lat: ${_submittedReport?.location.latitude}, Long: ${_submittedReport?.location.longitude}"),
            const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _sheetItem(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 15),
    ],
  );
}