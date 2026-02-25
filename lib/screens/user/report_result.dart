import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportResultPage extends StatelessWidget {
  final Report report;
  const ReportResultPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF387664),
        title: const Text("Report Detail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(report.status == 'pending' ? Icons.timer_outlined : Icons.check_circle_outline, size: 24, color: const Color(0xFF387664)),
                const SizedBox(width: 10),
                Text(
                  report.status == 'pending' ? "Report is pending" : "Report is ${report.status}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildImageHeader(),
            const SizedBox(height: 20),
            _infoRow(context, "Category", report.aiAnalysis?.category ?? "Unknown", true, () => _showCategorySheet(context)),
            _infoRow(context, "Date", DateFormat('MMM dd, yyyy').format(report.createdAt.toDate()), false, null),
            _infoRow(context, "Location", report.locationName.isNotEmpty ? report.locationName : "Unknown", true, () => _showLocationSheet(context)),
            _infoRow(context, "Weight", (report.aiAnalysis?.estimatedWeightKg ?? "Unknown").toString(), false, null),
            _infoRow(context, "Est. Cost for collection", (report.aiAnalysis?.estimatedCost ?? "N/A").toString(), false, null),
            _infoRow(context, "Company", report.matchedCompanyId ?? "Not assigned", report.matchedCompanyId != null, report.matchedCompanyId != null ? () => _showCompanySheet(context) : null),
            const SizedBox(height: 20),
            if (report.aiAnalysis != null) _buildAIResultDetails(),
            const SizedBox(height: 30),
            if (report.userId == AuthService().currentUser?.uid && report.status != 'completed')
              Column(
                children: [
                  if (report.status == 'approved')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final reportService = ReportService();
                          final notifService = NotificationService();
                          
                          // 1. Mark as collected
                          await reportService.markAsCollected(report.reportId);
                          
                          // 2. Notify reporter (owner)
                          await notifService.sendNotification(
                            NotificationModel(
                              id: '',
                              recipientId: report.userId,
                              title: "Waste Collected",
                              subtitle: "The waste from your report '${report.aiAnalysis?.category ?? 'waste'}' has been collected.",
                              type: 'collection_completed',
                              relatedId: report.reportId,
                              time: Timestamp.now(),
                            )
                          );

                          // 3. Notify volunteer
                          final volunteerId = await notifService.getVolunteerIdForReport(report.reportId);
                          if (volunteerId != null) {
                            await notifService.sendNotification(
                              NotificationModel(
                                id: '',
                                recipientId: volunteerId,
                                title: "Waste Collected",
                                subtitle: "The waste collection for '${report.aiAnalysis?.category ?? 'waste'}' is completed.",
                                type: 'collection_completed',
                                relatedId: report.reportId,
                                time: Timestamp.now(),
                              )
                            );
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Marked as collected!")),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF387664),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Mark as Collected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ReportService().deleteReport(report.reportId);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Cancel Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: report.imageUrl.startsWith('http')
              ? Image.network(report.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100))
              : Image.memory(base64Decode(report.imageUrl), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100)),
        ),
        Positioned(
          top: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: report.isPublic ? const Color(0xFF387664) : Colors.grey, borderRadius: BorderRadius.circular(20)),
            child: Text(report.isPublic ? "Public" : "Private", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, bool arrow, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.black54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664))),
          if (arrow) const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }

  Widget _buildAIResultDetails() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFB5D1C1), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          const Row(children: [Icon(Icons.smart_toy_outlined, size: 20), SizedBox(width: 10), Text("AI Analysis Details", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          _ResultItem(label: "Detected Waste Type", val: report.aiAnalysis?.category ?? "N/A"),
          _ResultItem(label: "Recyclable", val: report.aiAnalysis?.isRecyclable == true ? "Yes" : "No"),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Category Details", style: TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _sheetItem("Category", report.aiAnalysis?.category ?? "N/A"),
            _sheetItem("Description", report.description),
            const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Location Details", style: TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _sheetItem("Reported Location", report.locationName),
            _sheetItem("Geolocation", "Lat: ${report.location.latitude}, Long: ${report.location.longitude}"),
            const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  void _showCompanySheet(BuildContext context) {
    if (report.matchedCompanyId == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(report.matchedCompanyId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = data['companyName'] ?? data['username'] ?? 'Unknown Company';
          final address = (data['serviceAreas'] as List?)?.join(", ") ?? 'N/A';
          final phone = data['email'] ?? 'N/A'; // Using email as fallback for contact

          return Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Company Details", style: TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _sheetItem("Company Name", name),
                _sheetItem("Address", address),
                _sheetItem("Phone", phone),
                const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.orange)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sheetItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label, val;
  const _ResultItem({required this.label, required this.val});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: const TextStyle(fontSize: 12)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],
    ),
  );
}