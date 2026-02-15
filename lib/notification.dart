// import 'package:flutter/material.dart';
//
// // =============================================================================
// // SECTION 1: STYLE DEFINITIONS
// // =============================================================================
// class NotifStyles {
//   static const Color headerTeal = Color(0xFF387664);
//   static const Color backgroundMint = Color(0xFFE8F3ED);
//   static const Color textGrey = Color(0xFF757575);
//   static const String font = 'LexendExa';
// }
//
// // =============================================================================
// // SECTION 2: THE NOTIFICATION PAGE
// // =============================================================================
// class NotificationPage extends StatelessWidget {
//   const NotificationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: NotifStyles.backgroundMint,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: Container(
//           color: NotifStyles.headerTeal,
//           padding: const EdgeInsets.only(top: 40, left: 10),
//           alignment: Alignment.centerLeft,
//           child: Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               const Text(
//                 "Notification",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: NotifStyles.font,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle("Previously"),
//             const _NotificationCard(
//               title: "Collection Success!",
//               subtitle: "Your waste at Parit Jawa was collected.",
//               time: "2:46pm",
//             ),
//             const _NotificationCard(
//               title: "Company Match",
//               subtitle: "GreenCycle is on the way!",
//               time: "12:46pm",
//             ),
//             const _NotificationCard(
//               title: "New Request",
//               subtitle: "A volunteer requested to pick up your \"Old Chair.\"",
//               time: "8:21am",
//             ),
//
//             const SizedBox(height: 20),
//
//             // --- SECTION: A WEEK AGO ---
//             _buildSectionTitle("A week ago"),
//             const _NotificationCard(
//               title: "AI Analysis Done",
//               subtitle: "Your report has been categorized as 'Metal'.",
//               time: "11:41am",
//             ),
//
//             const SizedBox(height: 20),
//
//             // --- SECTION: A MONTH AGO ---
//             _buildSectionTitle("A month ago"),
//             const _NotificationCard(
//               title: "Welcome!",
//               subtitle: "Your business account for [Company Name] is active.",
//               time: "7:32pm",
//             ),
//
//             const SizedBox(height: 100), // Space for bottom nav
//           ],
//         ),
//       ),
//       // --- CUSTOM BOTTOM NAVIGATION BAR ---
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15, left: 5),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           fontFamily: NotifStyles.font,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNav() {
//     return Container(
//       height: 70,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.black12, width: 1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: const [
//           Icon(Icons.home_outlined, size: 32),
//           Icon(Icons.menu_book_outlined, size: 30),
//           Icon(Icons.notifications, size: 30, color: Colors.black), // Active State
//           Icon(Icons.map_outlined, size: 30),
//           Icon(Icons.person_outline, size: 32),
//         ],
//       ),
//     );
//   }
// }
//
// // =============================================================================
// // SECTION 3: REUSABLE NOTIFICATION CARD
// // =============================================================================
// class _NotificationCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String time;
//
//   const _NotificationCard({
//     required this.title,
//     required this.subtitle,
//     required this.time,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // The SmartWaste Logo Icon
//           Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.recycling, color: NotifStyles.headerTeal),
//           ),
//           const SizedBox(width: 15),
//           // Text Content
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                     ),
//                     Text(
//                       time,
//                       style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

// =============================================================================
// SECTION 1: STYLE DEFINITIONS
// =============================================================================
class NotifStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color textGrey = Color(0xFF757575);
  static const String font = 'LexendExa';
}

// =============================================================================
// SECTION 2: THE NOTIFICATION PAGE (TAB VERSION)
// =============================================================================
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold and AppBar because MainBasePage provides them.
    return Container(
      color: NotifStyles.backgroundMint,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text since the AppBar is now handled by the Base
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B3022), // Matching your homepage style
                ),
              ),
            ),

            _buildSectionTitle("Previously"),
            const _NotificationCard(
              title: "Collection Success!",
              subtitle: "Your waste at Parit Jawa was collected.",
              time: "2:46pm",
            ),
            const _NotificationCard(
              title: "Company Match",
              subtitle: "GreenCycle is on the way!",
              time: "12:46pm",
            ),
            const _NotificationCard(
              title: "New Request",
              subtitle: "A volunteer requested to pick up your \"Old Chair.\"",
              time: "8:21am",
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("A week ago"),
            const _NotificationCard(
              title: "AI Analysis Done",
              subtitle: "Your report has been categorized as 'Metal'.",
              time: "11:41am",
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("A month ago"),
            const _NotificationCard(
              title: "Welcome!",
              subtitle: "Your business account is active.",
              time: "7:32pm",
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: NotifStyles.font,
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 3: REUSABLE NOTIFICATION CARD (UNCHANGED)
// =============================================================================
class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.recycling, color: NotifStyles.headerTeal),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}