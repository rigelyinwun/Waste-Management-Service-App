import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import 'waste_profile.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportService _reportService = ReportService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  String _searchQuery = "";
  AppUser? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _userService.fetchUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _currentUser = profile;
          _isLoadingUser = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFE6F1ED);
    const headerGreen = Color(0xFF2E746A);
    const cardGreen = Color(0xFFC7E2D5);
    const pillGreen = Color(0xFF387664);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Reports Overview",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: headerGreen,
                    fontFamily: "Lexend",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search reports...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: _isLoadingUser 
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<Report>>(
                  stream: _currentUser?.role == 'business'
                      ? _reportService.getReportsByCompany(_currentUser!.uid)
                      : _reportService.getAllReports(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No reports found."));
                    }

                    final filtered = snapshot.data!.where((r) {
                      if (_searchQuery.isEmpty) return true;
                      final query = _searchQuery.toLowerCase();
                      return r.description.toLowerCase().contains(query) ||
                          (r.aiAnalysis?.category.toLowerCase().contains(query) ?? false);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text("No matching reports."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WasteProfilePage(report: r),
                              ),
                            ),
                            child: ReportCard(
                              report: r,
                              cardGreen: cardGreen,
                              pillGreen: pillGreen,
                              headerGreen: headerGreen,
                              onReject: () => _handleReject(r),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReject(Report r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Report?"),
        content: const Text("This will notify the user and start a rematching process."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Logic for rejection: update status to 'rejected' or similar
      await _reportService.updateReportStatus(r.reportId, "rejected");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report rejected. Rematching initiated.")),
        );
      }
    }
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final Color cardGreen;
  final Color pillGreen;
  final Color headerGreen;
  final VoidCallback onReject;

  const ReportCard({
    super.key,
    required this.report,
    required this.cardGreen,
    required this.pillGreen,
    required this.headerGreen,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: report.imageUrl.startsWith('http')
                  ? Image.network(report.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                  : Image.memory(base64Decode(report.imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  report.aiAnalysis?.category ?? "Unknown",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerGreen,
                    fontFamily: "Lexend",
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  report.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pillGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Status: ${report.status}",
                        style: TextStyle(fontSize: 12, color: headerGreen, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onReject,
                        child: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
