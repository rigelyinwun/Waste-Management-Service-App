import 'package:flutter/material.dart';

class SubmissionSuccessPage extends StatelessWidget {
  const SubmissionSuccessPage({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: AppBar(
        title: const Text("Report Waste"),
        backgroundColor: const Color(0xFF387664),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black, size: 24),
                SizedBox(width: 10),
                Text("Your report is submitted!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            Stack(
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
                    child: const Text("Public", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            _infoTile("Category", "Metal", () => _showDetailSheet(context, "Category Details")),
            _infoTile("Date", "Feb 10, 2026", () => _showDetailSheet(context, "Report Timeline")),
            _infoTile("Location", "Jalan Sri Emas, Cyberjaya", () => _showDetailSheet(context, "Location Details")),
            _infoTile("Weight", "Approx. 60 kg", null),
            _infoTile("Est. Cost", "RM150 - RM300", null),
            _infoTile("Expected Company", "Green Earth", null),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFB5D1C1), borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Row(children: [Icon(Icons.adb, size: 20), SizedBox(width: 10), Text("Result Details", style: TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 10),
                  _rowDetail("Detected Waste Type", "Construction Debris"),
                  _rowDetail("Suggested Category", "Metal"),
                  _rowDetail("Confidence Level", "92%"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.black54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664))),
          if (onTap != null) const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showDetailSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(title, style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            if (title.contains("Location")) ...[
              const Text("Address: Jalan Sri Emas, Cyberjaya", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 15),
              ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network('https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=400', height: 100, width: double.infinity, fit: BoxFit.cover)),
            ],
            const SizedBox(height: 30),
            const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
          ],
        ),
      ),
    );
  }
  Widget _rowDetail(String label, String val) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]));
}