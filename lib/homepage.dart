import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// =========================================================================
// STYLES
// =========================================================================
class SmartWasteStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB);
  static const Color accentGreen = Color(0xFF28B446);
  static const Color textDark = Color(0xFF1B3022);
}

// =========================================================================
// HOME PAGE (CONTENT ONLY)
// =========================================================================
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text(
              "SmartWaste",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
              child: Text(
                "My Pending Requests",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: SmartWasteStyles.textDark,
                ),
              ),
            ),

            // --- CENTERED HORIZONTAL LIST ---
            // The combination of Center and SingleChildScrollView with a Row
            // keeps the items in the middle when there are only a few.
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 20),
                    RequestCard(
                      category: "Fabric",
                      status: "Matching Company",
                      icon: Icons.checkroom,
                    ),
                    RequestCard(
                      category: "Furniture",
                      status: "Pending Pickup",
                      icon: Icons.chair,
                    ),
                    RequestCard(
                      category: "Metal",
                      status: "Company Assigned",
                      icon: Icons.layers,
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- DISPOSE ACTION BOX ---
            const Center(child: DisposeActionBox()),

            const SizedBox(height: 30),

            // --- REAL INTERACTIVE MAP ---
            const RealWasteMap(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// REAL DYNAMIC MAP
// =========================================================================
class RealWasteMap extends StatefulWidget {
  const RealWasteMap({super.key});

  @override
  State<RealWasteMap> createState() => _RealWasteMapState();
}

class _RealWasteMapState extends State<RealWasteMap> {
  // Initial camera position (Example: Kuala Lumpur)
  static const CameraPosition _initialPos = CameraPosition(
    target: LatLng(3.1390, 101.6869),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: const GoogleMap(
          initialCameraPosition: _initialPos,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
        ),
      ),
    );
  }
}

// =========================================================================
// UI COMPONENTS
// =========================================================================

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
    return Container(
      width: 160,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Icon(icon, size: 50, color: SmartWasteStyles.headerTeal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                  "AI Category:",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          )
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.add_circle, color: SmartWasteStyles.accentGreen, size: 80),
          SizedBox(height: 15),
          Text(
            "Dispose of Something New",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: SmartWasteStyles.textDark,
            ),
          ),
        ],
      ),
    );
  }
}