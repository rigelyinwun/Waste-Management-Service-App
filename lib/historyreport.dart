import 'package:flutter/material.dart';
import 'volunteercollected.dart';

class WasteReport {
  final String category;
  final String date;
  final String location;
  final String status;
  final IconData icon;
  final String weight;
  final String vehicle;
  final String description;

  WasteReport({
    required this.category,
    required this.date,
    required this.location,
    required this.status,
    required this.icon,
    required this.weight,
    required this.vehicle,
    required this.description,
  });
}

// =====================
// HISTORY PAGE
// =====================
class HistoryReportPage extends StatelessWidget {
  const HistoryReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<WasteReport> reports = [
      WasteReport(
        category: "Furniture",
        date: "Feb 12, 2026",
        location: "Kuala Lumpur",
        status: "Pending",
        icon: Icons.chair,
        weight: "45kg",
        vehicle: "Van",
        description: "Used sofa set, still in good condition",
      ),
      WasteReport(
        category: "Electronics",
        date: "Feb 10, 2026",
        location: "Cyberjaya",
        status: "Completed",
        icon: Icons.computer,
        weight: "12kg",
        vehicle: "Truck",
        description: "Old laptop and monitor",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("History Report"),
        backgroundColor: const Color(0xFF387664),
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(report.icon, color: const Color(0xFF387664)),
              title: Text(report.category),
              subtitle: Text("${report.date} • ${report.location}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VolunteerCollectedPage(report: report),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
