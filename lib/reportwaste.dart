import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int currentStep = 0;
  bool isPublic = true;

  @override
  Widget build(BuildContext context) {
    if (currentStep == 0) return _buildInitialForm();
    if (currentStep == 1) return _buildScanningView();
    return _buildSubmissionResult();
  }

  Widget _buildInitialForm() {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: _buildAppBar("Report Waste"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload Photos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => setState(() => currentStep = 1),
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFAED6BE), borderRadius: BorderRadius.circular(20)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.image_outlined, size: 50, color: Colors.black38),
                  Text("Preview", style: TextStyle(color: Colors.black38)),
                ]),
              ),
            ),
            const SizedBox(height: 25),
            _customLabel("Description"),
            _customField("Add condition, quantity, urgency..."),
            const SizedBox(height: 20),
            _customLabel("Location"),
            _customField("Select Location", icon: Icons.location_on),
            const SizedBox(height: 25),
            _buildPublicToggle(),
            const SizedBox(height: 30),
            _primaryButton("Submit Report", () => setState(() => currentStep = 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: _buildAppBar("Report Waste"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Align(alignment: Alignment.centerLeft, child: Text("Scan Item", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network('https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=500', height: 350, fit: BoxFit.cover),
                ),
                Container(height: 300, width: 300, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4FD195), width: 3), borderRadius: BorderRadius.circular(15))),
              ],
            ),
            const SizedBox(height: 25),
            _scanButton(Icons.camera_alt, "Capture Photo", const Color(0xFF82D69A), () {}),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: _scanButton(Icons.undo, "Retake", const Color(0xFFB5D1C1), () => setState(() => currentStep = 0))),
              const SizedBox(width: 15),
              Expanded(child: _scanButton(Icons.upload, "Upload", const Color(0xFFB5D1C1), () => setState(() => currentStep = 0))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionResult() {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: _buildAppBar("Report Waste"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(children: [Icon(Icons.check, size: 28), SizedBox(width: 10), Text("Your report is submitted!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 15),
            ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network('https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=500', height: 180, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 20),
            _resultTile("Category", "Metal", () => _showCategorySheet()),
            _resultTile("Date", "Feb 10, 2026", () => _showTimelineSheet()),
            _resultTile("Location", "Jalan Sri Emas, Cyberjaya", () => _showLocationSheet()),
            _resultTile("Weight", "Approx. 60 kg", () {}),
            const SizedBox(height: 20),
            _buildResultDetailsBox(),
            const SizedBox(height: 30),
            _primaryButton("Back to Form", () => setState(() => currentStep = 0)),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E5E4E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Category Details", style: TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const ListTile(leading: Icon(Icons.category, color: Colors.white), title: Text("Metal", style: TextStyle(color: Colors.white))),
            const Divider(color: Colors.white24),
            const Text("Sub-category: Concrete, Bricks", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) => AppBar(
    backgroundColor: const Color(0xFF387664),
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  Widget _customLabel(String text) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _customField(String hint, {IconData? icon}) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF387664)) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );

  Widget _buildPublicToggle() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Allow Public Collection?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Switch(value: isPublic, activeColor: const Color(0xFF387664), onChanged: (v) => setState(() => isPublic = v))]);

  Widget _primaryButton(String text, VoidCallback onTap) => SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E5E4E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: onTap, child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18))));

  Widget _scanButton(IconData icon, String label, Color color, VoidCallback onTap) => ElevatedButton.icon(onPressed: onTap, icon: Icon(icon, color: Colors.white), label: Text(label, style: const TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  Widget _resultTile(String label, String value, VoidCallback onTap) => ListTile(
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    trailing: Text("$value >", style: const TextStyle(color: Colors.black54)),
    onTap: onTap,
  );

  Widget _buildResultDetailsBox() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: const Color(0xFFCDE2D6), borderRadius: BorderRadius.circular(15)),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Result Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 5),
        Text("Detected Type: Construction Debris\nConfidence: 92%", style: TextStyle(height: 1.5)),
      ],
    ),
  );

  void _showTimelineSheet() { /* Similar to Category Sheet */ }
  void _showLocationSheet() { /* Similar to Category Sheet */ }
}