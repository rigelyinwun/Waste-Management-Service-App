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

  // Filter state
  String? _selectedCategory;
  String? _selectedStatus;
  DateTime? _selectedDate;

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
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: (_selectedCategory != null || _selectedStatus != null || _selectedDate != null)
                            ? headerGreen
                            : Colors.grey,
                      ),
                      onPressed: _openFilterDialog,
                    ),
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
                  stream: (_currentUser?.role.toLowerCase() == 'business' || 
                           _currentUser?.role.toLowerCase() == 'company' || 
                           _currentUser?.role.toLowerCase() == 'admin')
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
                      // Search Query Filter
                      bool matchesSearch = true;
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        matchesSearch = r.description.toLowerCase().contains(query) ||
                            (r.aiAnalysis?.category.toLowerCase().contains(query) ?? false);
                      }
                      if (!matchesSearch) return false;

                      // Category Filter
                      if (_selectedCategory != null && r.aiAnalysis?.category != _selectedCategory) {
                        return false;
                      }

                      // Status Filter
                      if (_selectedStatus != null && r.status != _selectedStatus?.toLowerCase()) {
                        return false;
                      }

                      // Date Filter
                      if (_selectedDate != null) {
                        final reportDate = r.createdAt.toDate();
                        if (reportDate.year != _selectedDate!.year ||
                            reportDate.month != _selectedDate!.month ||
                            reportDate.day != _selectedDate!.day) {
                          return false;
                        }
                      }

                      return true;
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

  void _openFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilterDialog(
        initialCategory: _selectedCategory,
        initialStatus: _selectedStatus,
        initialDate: _selectedDate,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result['category'];
        _selectedStatus = result['status'];
        _selectedDate = result['date'];
      });
    }
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

class _FilterDialog extends StatefulWidget {
  final String? initialCategory;
  final String? initialStatus;
  final DateTime? initialDate;

  const _FilterDialog({
    this.initialCategory,
    this.initialStatus,
    this.initialDate,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  String? _category;
  String? _status;
  DateTime? _date;

  final List<String> _categories = ["Metal", "Paper-based", "Cloth", "Furniture", "E-Waste", "Plastic", "Glass"];
  final List<String> _statuses = ["Pending", "Approved", "Collected", "Rejected"];

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _status = widget.initialStatus;
    _date = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    const headerGreen = Color(0xFF2E746A);
    const cardBg = Color(0xFFD3E6DB);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: headerGreen, fontFamily: "Lexend"),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Lexend")),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String?>(
                value: _category,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("All Categories"),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text("All Categories")),
                  ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Lexend")),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String?>(
                value: _status,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("All Statuses"),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text("All Statuses")),
                  ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Lexend")),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _date == null ? "Select Date" : "${_date!.day}/${_date!.month}/${_date!.year}",
                  style: TextStyle(color: _date == null ? Colors.grey[600] : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _category = null;
                        _status = null;
                        _date = null;
                      });
                    },
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: headerGreen),
                    onPressed: () => Navigator.pop(context, {'category': _category, 'status': _status, 'date': _date}),
                    child: const Text("Apply", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
