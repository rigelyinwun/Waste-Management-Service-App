import 'package:flutter/material.dart';

class VolunteerCollectedPage extends StatefulWidget {
  final dynamic report;
  const VolunteerCollectedPage({super.key, required this.report});
  @override
  State<VolunteerCollectedPage> createState() => _VolunteerCollectedPageState();
}

class _VolunteerCollectedPageState extends State<VolunteerCollectedPage> {
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF387664)),
            ),
            const SizedBox(height: 20),
            // Example of using the dynamic report data
            _detailRow("Category:", widget.report?.toString() ?? "N/A"),
            const SizedBox(height: 10),
            const Text(
              "You can now manage the collection of this waste report.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}