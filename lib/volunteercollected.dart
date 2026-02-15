import 'package:flutter/material.dart';
import 'historyreport.dart';

class VolunteerCollectedPage extends StatefulWidget {
  final WasteReport report;

  const VolunteerCollectedPage({
    super.key,
    required this.report,
  });

  @override
  State<VolunteerCollectedPage> createState() =>
      _VolunteerCollectedPageState();
}

class _VolunteerCollectedPageState extends State<VolunteerCollectedPage> {
  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF387664),
        title: Text(
          "${widget.report.category} Collection",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isConfirmed ? _pickupView() : _detailView(),
    );
  }

  // =====================
  // ITEM DETAIL VIEW
  // =====================
  Widget _detailView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoCard(),
          const SizedBox(height: 20),
          _confirmBox(),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.report.description,
              style: const TextStyle(fontSize: 15)),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconInfo(Icons.scale, widget.report.weight),
              _iconInfo(Icons.local_shipping, widget.report.vehicle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _confirmBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Text(
            "Volunteer to collect this item?",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => setState(() => isConfirmed = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // =====================
  // PICKUP VIEW
  // =====================
  Widget _pickupView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pickup Address",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Lorong 5, Residences, 55200 KL"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Mark as Collected"),
          ),
        ],
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
