// // import 'package:flutter/material.dart';
// // // Note: Ensure you have run 'flutter pub add google_maps_flutter' in your terminal
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// //
// // // =========================================================================
// // // STYLES
// // // =========================================================================
// // class SmartWasteStyles {
// //   static const Color headerTeal = Color(0xFF387664);
// //   static const Color backgroundMint = Color(0xFFD3E6DB);
// //   static const Color accentGreen = Color(0xFF28B446);
// //   static const Color textDark = Color(0xFF1B3022);
// // }
// //
// // class HomePage extends StatelessWidget {
// //   const HomePage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: SmartWasteStyles.backgroundMint,
// //       appBar: AppBar(
// //         backgroundColor: SmartWasteStyles.headerTeal,
// //         elevation: 0,
// //         centerTitle: true,
// //         title: const Text(
// //           "SmartWaste",
// //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
// //         ),
// //       ),
// //       bottomNavigationBar: const CustomBottomNav(),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Padding(
// //               padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
// //               child: Text(
// //                 "My Pending Requests",
// //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: SmartWasteStyles.textDark),
// //               ),
// //             ),
// //
// //             // --- CENTERED DYNAMIC REQUEST SECTION ---
// //             Center(
// //               child: SizedBox(
// //                 height: 220,
// //                 // Removed 'const' from children below to fix your error
// //                 child: ListView(
// //                   shrinkWrap: true,
// //                   scrollDirection: Axis.horizontal,
// //                   padding: const EdgeInsets.symmetric(horizontal: 15),
// //                   children: [
// //                     RequestCard(category: "Fabric", status: "Matching Company", icon: Icons.checkroom),
// //                     RequestCard(category: "Furniture", status: "Pending Pickup", icon: Icons.chair),
// //                     RequestCard(category: "Metal", status: "Company Assigned", icon: Icons.layers),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 30),
// //
// //             // Removed 'const' here
// //             Center(child: DisposeActionBox()),
// //
// //             const SizedBox(height: 30),
// //
// //             // REAL INTERACTIVE MAP
// //             const RealWasteMap(),
// //
// //             const SizedBox(height: 50),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // =========================================================================
// // // REAL DYNAMIC MAP WIDGET
// // // =========================================================================
// // class RealWasteMap extends StatefulWidget {
// //   const RealWasteMap({super.key});
// //
// //   @override
// //   State<RealWasteMap> createState() => _RealWasteMapState();
// // }
// //
// // class _RealWasteMapState extends State<RealWasteMap> {
// //   // LatLng and CameraPosition come from the google_maps_flutter package
// //   static const CameraPosition _initialPosition = CameraPosition(
// //     target: LatLng(3.1390, 101.6869),
// //     zoom: 14.0,
// //   );
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20),
// //       height: 350,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(30),
// //         border: Border.all(color: Colors.white, width: 4),
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(26),
// //         child: const GoogleMap(
// //           initialCameraPosition: _initialPosition,
// //           mapType: MapType.normal,
// //           myLocationButtonEnabled: false,
// //           zoomControlsEnabled: false,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // =========================================================================
// // // REUSABLE COMPONENTS
// // // =========================================================================
// //
// // class RequestCard extends StatelessWidget {
// //   final String category;
// //   final String status;
// //   final IconData icon;
// //
// //   const RequestCard({super.key, required this.category, required this.status, required this.icon});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 160,
// //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
// //       ),
// //       child: Column(
// //         children: [
// //           Expanded(
// //             child: Container(
// //               width: double.infinity,
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[100],
// //                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
// //               ),
// //               child: Icon(icon, size: 50, color: SmartWasteStyles.headerTeal),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               children: [
// //                 const Text("AI Category:", style: TextStyle(fontSize: 10, color: Colors.grey)),
// //                 Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
// //                 const SizedBox(height: 4),
// //                 Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
// //               ],
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class DisposeActionBox extends StatelessWidget {
// //   const DisposeActionBox({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: MediaQuery.of(context).size.width * 0.9,
// //       padding: const EdgeInsets.symmetric(vertical: 30),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(25),
// //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
// //       ),
// //       child: Column(
// //         children: [
// //           const Icon(Icons.add_circle, color: SmartWasteStyles.accentGreen, size: 80),
// //           const SizedBox(height: 15),
// //           const Text(
// //             "Dispose of Something New",
// //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SmartWasteStyles.textDark),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class CustomBottomNav extends StatelessWidget {
// //   const CustomBottomNav({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return BottomNavigationBar(
// //       type: BottomNavigationBarType.fixed,
// //       selectedItemColor: SmartWasteStyles.headerTeal,
// //       unselectedItemColor: Colors.black38,
// //       items: const [
// //         BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
// //         BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: ""),
// //         BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ""),
// //         BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: ""),
// //         BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
// //       ],
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// // =========================================================================
// // STYLES
// // =========================================================================
// class SmartWasteStyles {
//   static const Color headerTeal = Color(0xFF387664);
//   static const Color backgroundMint = Color(0xFFD3E6DB);
//   static const Color accentGreen = Color(0xFF28B446);
//   static const Color textDark = Color(0xFF1B3022);
// }
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: SmartWasteStyles.backgroundMint,
//       appBar: AppBar(
//         backgroundColor: SmartWasteStyles.headerTeal,
//         elevation: 0,
//         centerTitle: true,
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Icon(Icons.recycling, color: Colors.greenAccent),
//             SizedBox(width: 8),
//             Text(
//               "SmartWaste",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const CustomBottomNav(),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
//               child: Text(
//                 "My Pending Requests",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: SmartWasteStyles.textDark),
//               ),
//             ),
//
//             // 1. CENTERED PENDING REQUESTS
//             // Wrapping in Center + SingleChildScrollView + Row ensures horizontal
//             // scrolling while keeping them in the middle of the screen.
//             Center(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(width: 20),
//                     RequestCard(category: "Fabric", status: "Matching Company", icon: Icons.checkroom),
//                     RequestCard(category: "Furniture", status: "Pending Pickup", icon: Icons.chair),
//                     RequestCard(category: "Metal", status: "Company Assigned", icon: Icons.layers),
//                     const SizedBox(width: 20),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // 2. DISPOSE ACTION BOX
//             Center(child: DisposeActionBox()),
//
//             const SizedBox(height: 30),
//
//             // 3. REAL DYNAMIC MAP
//             const RealWasteMap(),
//
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // =========================================================================
// // REAL DYNAMIC MAP
// // =========================================================================
// class RealWasteMap extends StatefulWidget {
//   const RealWasteMap({super.key});
//
//   @override
//   State<RealWasteMap> createState() => _RealWasteMapState();
// }
//
// class _RealWasteMapState extends State<RealWasteMap> {
//   // Center coordinates (Kuala Lumpur example)
//   static const CameraPosition _initialPos = CameraPosition(
//     target: LatLng(3.1390, 101.6869),
//     zoom: 14,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       height: 350,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: Colors.white, width: 4),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(26),
//         child: GoogleMap(
//           initialCameraPosition: _initialPos,
//           mapType: MapType.normal,
//           zoomControlsEnabled: false,
//           myLocationButtonEnabled: false,
//         ),
//       ),
//     );
//   }
// }
//
// // =========================================================================
// // COMPONENTS
// // =========================================================================
//
// class RequestCard extends StatelessWidget {
//   final String category;
//   final String status;
//   final IconData icon;
//
//   const RequestCard({super.key, required this.category, required this.status, required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 160,
//       height: 200,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Icon(icon, size: 50, color: SmartWasteStyles.headerTeal),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 const Text("AI Category:", style: TextStyle(fontSize: 10, color: Colors.grey)),
//                 Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                 const SizedBox(height: 4),
//                 Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class DisposeActionBox extends StatelessWidget {
//   const DisposeActionBox({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.9,
//       padding: const EdgeInsets.symmetric(vertical: 30),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
//       ),
//       child: Column(
//         children: const [
//           Icon(Icons.add_circle, color: SmartWasteStyles.accentGreen, size: 80),
//           SizedBox(height: 15),
//           Text(
//             "Dispose of Something New",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SmartWasteStyles.textDark),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomBottomNav extends StatelessWidget {
//   const CustomBottomNav({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: SmartWasteStyles.headerTeal,
//       unselectedItemColor: Colors.black38,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "homepage"),
//         BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "report"),
//         BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "notification"),
//         BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "location"),
//         BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "profilepage"),
//       ],
//     );
//   }
// }
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.recycling, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text(
              "SmartWaste",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
              child: Text(
                "My Pending Requests",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: SmartWasteStyles.textDark),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 20),
                    RequestCard(category: "Fabric", status: "Matching Company", icon: Icons.checkroom),
                    RequestCard(category: "Furniture", status: "Pending Pickup", icon: Icons.chair),
                    RequestCard(category: "Metal", status: "Company Assigned", icon: Icons.layers),
                    SizedBox(width: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(child: DisposeActionBox()),
            const SizedBox(height: 30),
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
        child: GoogleMap(
          initialCameraPosition: _initialPos,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}

// =========================================================================
// COMPONENTS
// =========================================================================
class RequestCard extends StatelessWidget {
  final String category;
  final String status;
  final IconData icon;

  const RequestCard({super.key, required this.category, required this.status, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
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
                const Text("AI Category:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: const [
          Icon(Icons.add_circle, color: SmartWasteStyles.accentGreen, size: 80),
          SizedBox(height: 15),
          Text(
            "Dispose of Something New",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SmartWasteStyles.textDark),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// BOTTOM NAVIGATION (ONLY CHANGE IS onTap)
// =========================================================================
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: SmartWasteStyles.headerTeal,
      unselectedItemColor: Colors.black38,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/homepage');
            break;
          case 1:
            Navigator.pushNamed(context, '/report');
            break;
          case 2:
            Navigator.pushNamed(context, '/notification');
            break;
          case 3:
            Navigator.pushNamed(context, '/location');
            break;
          case 4:
            Navigator.pushNamed(context, '/profilepage');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "homepage"),
        BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "report"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "notification"),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "location"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "profilepage"),
      ],
    );
  }
}
