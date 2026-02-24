import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class VolunteerCollectedPage extends StatefulWidget {
  final Report report;
  final String? volunteerId;
  const VolunteerCollectedPage({super.key, required this.report, this.volunteerId});
  @override
  State<VolunteerCollectedPage> createState() => _VolunteerCollectedPageState();
}

class _VolunteerCollectedPageState extends State<VolunteerCollectedPage> {
  final ReportService _reportService = ReportService();
  final NotificationService _notificationService = NotificationService();
  bool _isApproving = false;

  Future<void> _approveRequest() async {
    if (widget.volunteerId == null) return;

    setState(() => _isApproving = true);
    try {
      // 1. Update report status to approved
      await _reportService.updateReportStatus(widget.report.reportId, 'approved');

      // 2. Send notification to volunteer
      await _notificationService.sendNotification(
        NotificationModel(
          id: '',
          recipientId: widget.volunteerId!,
          title: "Request Approved",
          subtitle: "Your request to collect ${widget.report.aiAnalysis?.category ?? 'waste'} was approved. Please go collect.",
          type: 'request_approved',
          relatedId: widget.report.reportId,
          time: Timestamp.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request approved successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF387664),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Collection Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF387664)),
            ),
            const SizedBox(height: 20),
            
            // Image Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: widget.report.imageUrl.startsWith('http')
                  ? Image.network(widget.report.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100))
                  : Image.memory(base64Decode(widget.report.imageUrl), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100)),
            ),
            const SizedBox(height: 20),

            _detailRow("Category:", widget.report.aiAnalysis?.category ?? "N/A"),
            const SizedBox(height: 10),
            _detailRow("Description:", widget.report.description),
            const SizedBox(height: 20),
            const Text(
              "A volunteer has requested to collect this waste. By approving, you agree to let them handle the collection.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            if (widget.report.status == 'pending' || widget.report.status == 'matched' || widget.report.status == 'no_company_found')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isApproving ? null : _approveRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF387664),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isApproving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Approve Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            else if (widget.report.status == 'approved')
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF387664), size: 50),
                    SizedBox(height: 10),
                    Text(
                      "Request Already Approved",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664)),
                    ),
                  ],
                ),
              )
            else if (widget.report.status == 'completed')
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.done_all, color: Colors.blue, size: 50),
                    SizedBox(height: 10),
                    Text(
                      "Collection Completed",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF387664))),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}