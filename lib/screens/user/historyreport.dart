import 'package:flutter/material.dart';

class WasteReport {
  final String category;
  final String date;
  final String location;
  final String status;
  final IconData icon;
  final String weight;
  final String vehicle;
  final String description;
  final String collector;

  WasteReport({
    required this.category,
    required this.date,
    required this.location,
    required this.status,
    required this.icon,
    required this.weight,
    required this.vehicle,
    required this.description,
    required this.collector,
  });
}

class HistoryReportPage extends StatefulWidget {
  const HistoryReportPage({super.key});
  @override
  State<HistoryReportPage> createState() => _HistoryReportPageState();
}

class _HistoryReportPageState extends State<HistoryReportPage> {
  String selectedFilter = "All";
  final List<WasteReport> reports = [
    WasteReport(
      category: "Metal",
      date: "Feb 10, 2026",
      location: "Jalan Sri Emas, Cyberjaya",
      status: "Completed",
      icon: Icons.layers,
      weight: "15kg",
      vehicle: "Truck",
      description: "Industrial metal scraps.",
      collector: "Green Earth",
    ),
    WasteReport(
      category: "Furniture",
      date: "Feb 12, 2026",
      location: "Parit Jawa, Johor",
      status: "Pending",
      icon: Icons.chair,
      weight: "45kg",
      vehicle: "Van",
      description: "Used sofa set, still in good condition",
      collector: "WoodRetriever",
    ),
    WasteReport(
      category: "Cloth",
      date: "Feb 10, 2026",
      location: "Jalan Tasik, Putrajaya",
      status: "Pending",
      icon: Icons.checkroom,
      weight: "8kg",
      vehicle: "Car",
      description: "Old clothing items.",
      collector: "Ms Lim",
    ),
    WasteReport(
      category: "Paper-Based",
      date: "Feb 10, 2026",
      location: "Jalan Seroja, Muar",
      status: "Cancelled",
      icon: Icons.newspaper,
      weight: "120kg",
      vehicle: "Truck",
      description: "Newspapers and cardboard.",
      collector: "RecyclePro",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<WasteReport> filteredReports = reports.where((report) {
      if (selectedFilter == "All") return true;
      return report.status == selectedFilter;
    }).toList();

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
            color: Colors.white, // Title word is white
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
            child: filteredReports.isEmpty
                ? const Center(child: Text("No records found."))
                : ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return _buildReportCard(context, report);
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

  Widget _buildReportCard(BuildContext context, WasteReport report) {
    Color statusColor = report.status == "Completed"
        ? Colors.green
        : report.status == "Cancelled"
        ? Colors.red
        : Colors.orange;

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
              Icon(report.icon, size: 50, color: Colors.black87),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.category,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(report.date,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(report.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(report.collector,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                      report.status == "Completed"
                          ? Icons.check_circle
                          : report.status == "Cancelled"
                          ? Icons.cancel
                          : Icons.access_time_filled,
                      color: statusColor),
                  Text(report.status,
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
              Navigator.pushNamed(context, '/volunteercollected',
                  arguments: report);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FD195),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("View Details",
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}