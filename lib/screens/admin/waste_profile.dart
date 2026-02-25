import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/company_matching_service.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class WasteProfilePage extends StatefulWidget {
  final Report report;

  const WasteProfilePage({
    super.key,
    required this.report,
  });

  @override
  State<WasteProfilePage> createState() => _WasteProfileAdminPageState();
}

enum _CollectStatus { none, pending, collected }

class _WasteProfileAdminPageState extends State<WasteProfilePage> {
  late double _estimatedCostRm;
  late _CollectStatus _status;
  final ReportService _reportService = ReportService();
  final CompanyMatchingService _matchingService = CompanyMatchingService();
  final NotificationService _notificationService = NotificationService();
  bool _isSaving = false;
  bool _isRejecting = false;

  @override
  void initState() {
    super.initState();
    _estimatedCostRm = _parseCost((widget.report.aiAnalysis?.estimatedCost ?? "0").toString());
    _status = _CollectStatus.none; // Will need to be synced with backend status later
  }

  double _parseCost(String costStr) {
    final clean = costStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD3E6DB);
    const headerGreen = Color(0xFF387664);
    const cardBg = Color(0xFFB5D1C1);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: headerGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: _handleBack,
          ),
          title: const Text(
            "Waste Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "Lexend",
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageBlock(),
              const SizedBox(height: 20),
              _infoRow("Category", widget.report.aiAnalysis?.category ?? "Unknown"),
              _infoRow("Description", widget.report.description),
              _infoRow("Weight", "${widget.report.aiAnalysis?.estimatedWeightKg ?? 'N/A'} kg"),
              _infoRow("Recyclable", widget.report.aiAnalysis?.isRecyclable == true ? "Yes" : "No"),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.smart_toy_outlined, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Details & AI Metadata",
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Lexend"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _aiDetailItem("Recyclability Level", widget.report.aiAnalysis?.recyclabilityLevel ?? "Unknown"),
                    _aiDetailItem("Pickup Priority", widget.report.aiAnalysis?.pickupPriority ?? "Normal"),
                    _aiDetailItem("Collection Effort", widget.report.aiAnalysis?.collectionEffort ?? "Medium"),
                    _aiDetailItem("Recommended Transport", widget.report.aiAnalysis?.recommendedTransport ?? "None"),
                    _aiDetailItem("Logistics", widget.report.aiAnalysis?.logistics ?? "N/A"),
                    _aiDetailItem("Material Tag", widget.report.aiAnalysis?.materialTag ?? "N/A"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _estimatedCostSection(headerGreen),
              const SizedBox(height: 30),
              _bottomButtons(headerGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.black54, fontFamily: "Lexend")),
      trailing: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664), fontFamily: "Lexend"),
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _aiDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontFamily: "Lexend")),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: "Lexend"),
          ),
        ],
      ),
    );
  }

  Widget _imageBlock() {
    final report = widget.report;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 200,
            width: double.infinity,
            color: const Color(0xFFD9D9D9),
            child: report.imageUrl.startsWith('http')
                ? Image.network(report.imageUrl, fit: BoxFit.cover)
                : Image.memory(base64Decode(report.imageUrl), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: report.isPublic ? const Color(0xFF387664) : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              report.isPublic ? "Public" : "Private",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Lexend"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _estimatedCostSection(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estimated Costs (RM)",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Lexend"),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text("RM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Lexend")),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  _estimatedCostRm.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Lexend"),
                ),
              ),
              _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.save, color: Color(0xFF387664)),
                    onPressed: _onSaveCost,
                    tooltip: "Save Cost",
                  ),
              Column(
                children: [
                  InkWell(
                    onTap: () => _setCost(_estimatedCostRm + 10),
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                  InkWell(
                    onTap: () => _setCost((_estimatedCostRm - 10).clamp(0, 9999999)),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSaveCost() async {
    setState(() => _isSaving = true);
    try {
      final aiData = widget.report.aiAnalysis?.toMap() ?? {};
      aiData['estimatedCost'] = _estimatedCostRm;
      
      await _reportService.updateAIAnalysis(widget.report.reportId, aiData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Estimated cost updated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating cost: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _setCost(double v) {
    setState(() => _estimatedCostRm = v);
  }

  Widget _bottomButtons(Color themeColor) {
    final canRequest = _status == _CollectStatus.none;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: canRequest ? _onRequestCollectPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _status == _CollectStatus.pending ? "Requested" : "Request Collect",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Lexend"),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _onMarkCollectedPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _status == _CollectStatus.collected ? "Collected" : "Mark as Collected",
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontFamily: "Lexend"),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isRejecting ? null : _onRejectPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isRejecting 
              ? const CircularProgressIndicator(color: Colors.red)
              : const Text(
                  "Reject & Rematch",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: "Lexend"),
                ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRejectPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Report?", style: TextStyle(fontFamily: "Lexend")),
        content: const Text("This will reject the current match and trigger a rematch for this report. Continue?", style: TextStyle(fontFamily: "Lexend")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRejecting = true);
    try {
      // 1. Rematch
      final currentCompanyId = widget.report.matchedCompanyId;
      final newCompanyId = await _matchingService.findMatchingCompany(
        widget.report.aiAnalysis?.category ?? "",
        excludeCompanyId: currentCompanyId,
      );
      
      // 2. Update report
      await FirebaseFirestore.instance.collection('reports').doc(widget.report.reportId).update({
        'matchedCompanyId': newCompanyId,
        'status': newCompanyId != null ? 'matched' : 'no_company_found',
      });

      // 3. Send notification to user
      await _notificationService.sendNotification(
        NotificationModel(
          id: '',
          recipientId: widget.report.userId,
          title: "Report Match Rejected",
          subtitle: "Your report for ${widget.report.aiAnalysis?.category ?? 'waste'} was rejected by the previous match and is being rematched.",
          type: 'report_rejected',
          relatedId: widget.report.reportId,
          time: Timestamp.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report rejected and rematch triggered.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error rejecting report: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isRejecting = false);
    }
  }

  Future<void> _onRequestCollectPressed() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Request collect?", style: TextStyle(fontFamily: "Lexend")),
        content: const Text("Send a collection request to the user?", style: TextStyle(fontFamily: "Lexend")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF387664)),
            child: const Text("Send request", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (res == true) {
      setState(() => _status = _CollectStatus.pending);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request sent.")),
        );
      }
    }
  }

  void _onMarkCollectedPressed() {
    setState(() => _status = _CollectStatus.collected);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marked as collected.")),
    );
  }
}
