import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SmartWasteStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB);
  static const Color accentGreen = Color(0xFF28B446);
  static const Color textDark = Color(0xFF1B3022);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmartWasteStyles.backgroundMint,
      appBar: AppBar(
        backgroundColor: SmartWasteStyles.headerTeal,
        elevation: 0,
        centerTitle: true,
        // --- DIRECTLY REMOVED ARROW HERE ---
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text(
                "SmartWaste",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                "My Pending Requests",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: SmartWasteStyles.textDark
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      RequestCard(category: "Metal", status: "Matching", icon: Icons.layers),
                      RequestCard(category: "Fabric", status: "Pending", icon: Icons.checkroom),
                      RequestCard(category: "Furniture", status: "Assigned", icon: Icons.chair),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Center(child: DisposeActionBox()),
            const SizedBox(height: 30),
            const RealWasteMap(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String category;
  final String status;
  final IconData icon;

  const RequestCard({
    super.key,
    required this.category,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 60) / 3;

    return Container(
      width: cardWidth,
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Icon(icon, size: 28, color: SmartWasteStyles.headerTeal),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    bool isPending = status == "Pending";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFFDE7) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 8,
            color: isPending ? Colors.orange : SmartWasteStyles.accentGreen,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}

class DisposeActionBox extends StatelessWidget {
  const DisposeActionBox({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: const Column(
        children: [
          Icon(Icons.add_circle, color: SmartWasteStyles.accentGreen, size: 60),
          SizedBox(height: 8),
          Text(
            "Dispose of Something New",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: SmartWasteStyles.textDark
            ),
          ),
        ],
      ),
    );
  }
}

class RealWasteMap extends StatelessWidget {
  const RealWasteMap({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: const GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(3.1390, 101.6869), zoom: 14),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}