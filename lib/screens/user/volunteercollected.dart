import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
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
  final UserService _userService = UserService();
  bool _isProcessing = false;
  bool _actionTaken = false;
  String? _senderRole;

  @override
  void initState() {
    super.initState();
    _fetchSenderInfo();
  }

  Future<void> _fetchSenderInfo() async {
    if (widget.volunteerId != null) {
      final profile = await _userService.fetchUserProfile(widget.volunteerId!);
      if (mounted) {
        setState(() {
          _senderRole = profile?.role;
        });
      }
    }
  }

  Future<void> _handleAction(bool isApprove) async {
    if (widget.volunteerId == null || _actionTaken) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Fetch user profiles to get phone numbers
      final volunteerProfile = await _userService.fetchUserProfile(widget.volunteerId!);
      final ownerProfile = await _userService.fetchUserProfile(widget.report.userId);

      final volunteerPhone = volunteerProfile?.phoneNumber ?? "N/A";
      final ownerPhone = ownerProfile?.phoneNumber ?? "N/A";
      final isCompany = volunteerProfile?.role == 'company' || volunteerProfile?.role == 'admin';

      if (isApprove) {
        // Approve Logic
        await _reportService.updateReportStatus(widget.report.reportId, 'approved');

        // Notify Volunteer/Company
        await _notificationService.sendNotification(
          NotificationModel(
            id: '',
            recipientId: widget.volunteerId!,
            title: "Request Approved",
            subtitle: "Your request to collect ${widget.report.aiAnalysis?.category ?? 'waste'} was approved. Contact owner: $ownerPhone",
            type: 'request_approved',
            relatedId: widget.report.reportId,
            senderId: widget.report.userId,
            time: Timestamp.now(),
          ),
        );

        // Notify Owner (Confirmation)
        await _notificationService.sendNotification(
          NotificationModel(
            id: '',
            recipientId: widget.report.userId,
            title: "Collection Approved",
            subtitle: "You approved a ${isCompany ? 'company' : 'volunteer'} collection request. Contact: $volunteerPhone",
            type: 'collection_confirmation',
            relatedId: widget.report.reportId,
            senderId: widget.volunteerId,
            time: Timestamp.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request approved successfully!")),
          );
        }
      } else {
        // Reject Logic
        // Revert status to matched if it was a company request, or stay as it was
        final newStatus = isCompany ? 'matched' : (widget.report.matchedCompanyId != null ? 'matched' : 'pending');
        await _reportService.updateReportStatus(widget.report.reportId, newStatus);
        
        // Notify Volunteer/Company
        await _notificationService.sendNotification(
          NotificationModel(
            id: '',
            recipientId: widget.volunteerId!,
            title: "Request Rejected",
            subtitle: "Your request to collect ${widget.report.aiAnalysis?.category ?? 'waste'} was rejected by the owner.",
            type: 'request_rejected',
            relatedId: widget.report.reportId,
            senderId: widget.report.userId,
            time: Timestamp.now(),
          ),
        );

        // Notify Owner (Confirmation)
        await _notificationService.sendNotification(
          NotificationModel(
            id: '',
            recipientId: widget.report.userId,
            title: "Collection Rejected",
            subtitle: "You rejected the collection request.",
            type: 'collection_rejection',
            relatedId: widget.report.reportId,
            senderId: widget.volunteerId,
            time: Timestamp.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request rejected.")),
          );
        }
      }

      setState(() {
        _actionTaken = true;
      });
      
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
        title: Text(
          (_senderRole == 'company' || _senderRole == 'admin') ? "Company Collect" : "Collection Details",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Text(
              (_senderRole == 'company' || _senderRole == 'admin') 
                ? "A company has requested to collect this waste. By approving, you agree to let them handle the collection and provide your contact information."
                : "A volunteer has requested to collect this waste. By approving, you agree to let them handle the collection.",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            if ((widget.report.status == 'pending' || widget.report.status == 'matched' || widget.report.status == 'no_company_found' || widget.report.status == 'collecting') && !_actionTaken)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _handleAction(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF387664),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isProcessing 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Approve Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : () => _handleAction(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Reject Request", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              )
            else if (widget.report.status == 'approved' || _actionTaken)
              Center(
                child: Column(
                  children: [
                    Icon(
                      _actionTaken && widget.report.status != 'approved' ? Icons.cancel : Icons.check_circle, 
                      color: _actionTaken && widget.report.status != 'approved' ? Colors.red : const Color(0xFF387664), 
                      size: 50
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _actionTaken && widget.report.status != 'approved' ? "Request Rejected" : "Request Already Approved",
                      style: TextStyle(fontWeight: FontWeight.bold, color: _actionTaken && widget.report.status != 'approved' ? Colors.red : const Color(0xFF387664)),
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