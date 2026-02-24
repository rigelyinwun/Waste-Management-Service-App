import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import 'package:intl/intl.dart';
import 'report_result.dart';

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({super.key});
  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  String selectedFilter = "All";
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF387664),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "History Report",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  _buildFilterChip("All"),
                  _buildFilterChip("Completed"),
                  _buildFilterChip("Pending"),
                  _buildFilterChip("Cancelled"),
                ],
              ),
            ),
          ),

          Expanded(
            child: user == null
                ? const Center(child: Text("Please login to see history."))
                : StreamBuilder<List<Report>>(
                    stream: _reportService.getReportsByUser(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error loading reports: ${snapshot.error}"),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No records found."));
                      }

                      final reports = snapshot.data!.where((report) {
                        if (selectedFilter == "All") return true;
                        return report.status.toLowerCase() ==
                            selectedFilter.toLowerCase();
                      }).toList();

                      if (reports.isEmpty) {
                        return const Center(child: Text("No matching records."));
                      }

                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return _buildReportCard(context, report);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.5),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF387664) : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
    final status = report.status;
    Color statusColor = status.toLowerCase() == "completed"
        ? Colors.green
        : status.toLowerCase() == "cancelled"
            ? Colors.red
            : Colors.orange;

    String dateStr = DateFormat('MMM dd, yyyy').format(report.createdAt.toDate());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildReportIcon(report),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.aiAnalysis?.category ?? "analyzing...",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(dateStr,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(report.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (report.matchedCompanyId != null)
                      Text("Matched: ${report.matchedCompanyId}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                      status.toLowerCase() == "completed"
                          ? Icons.check_circle
                          : status.toLowerCase() == "cancelled"
                              ? Icons.cancel
                              : Icons.access_time_filled,
                      color: statusColor),
                  Text(status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportResultPage(report: report),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FD195),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("View Details",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildReportIcon(Report report) {
    final category = report.aiAnalysis?.category.toLowerCase() ?? "";
    IconData icon = Icons.layers;
    if (category.contains("metal")) icon = Icons.settings;
    if (category.contains("furniture")) icon = Icons.chair;
    if (category.contains("cloth")) icon = Icons.checkroom;
    if (category.contains("paper")) icon = Icons.newspaper;

    return Icon(icon, size: 50, color: Colors.black87);
  }
}