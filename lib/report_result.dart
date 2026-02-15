import 'package:flutter/material.dart';

class ReportResultPage extends StatelessWidget {
  const ReportResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF387664),
        title: const Text("Report Waste", style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.check, size: 24),
                SizedBox(width: 10),
                Text("Your report is submitted!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            _buildImageHeader(),
            const SizedBox(height: 20),
            _infoRow(context, "Category", "Metal", true, () => _showCategorySheet(context)),
            _infoRow(context, "Date", "Feb 10, 2026", true, () => _showTimelineSheet(context)),
            _infoRow(context, "Location", "Jalan Sri Emas, Cyberjaya", true, () => _showLocationSheet(context)),
            _infoRow(context, "Weight", "Approx. 60 kg", false, null),
            _infoRow(context, "Est. Cost", "RM150 - RM300", false, null),
            _infoRow(context, "Expected Company", "Green Earth", true, null),
            const SizedBox(height: 20),
            _buildAIResultDetails(),
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
          child: Image.network('https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=500', height: 180, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF387664), borderRadius: BorderRadius.circular(20)),
            child: const Text("Public", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
      child: const Column(
        children: [
          Row(children: [Icon(Icons.smart_toy_outlined, size: 20), SizedBox(width: 10), Text("Result Details", style: TextStyle(fontWeight: FontWeight.bold))]),
          SizedBox(height: 10),
          _ResultItem(label: "Detected Waste Type", val: "Construction Debris"),
          _ResultItem(label: "Suggested Category", val: "Metal"),
          _ResultItem(label: "Confidence Level", val: "92%"),
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
          children: [
            const Text("Category Details", style: TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _sheetItem("Primary Category", "Metal"),
            _sheetItem("Sub-category", "• Concrete, • Bricks, • Mixed Debris"),
            _sheetItem("Hazard Level", "Low Risk"),
            const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  void _showTimelineSheet(BuildContext context) {}
  void _showLocationSheet(BuildContext context) {}

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
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(label, style: const TextStyle(fontSize: 12)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],
  );
}