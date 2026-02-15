import 'package:flutter/material.dart';

class NotifStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color textGrey = Color(0xFF757575);
  static const String font = 'LexendExa';
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: const Color(0xFF387664),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotifStyles.backgroundMint,
      appBar: _buildAppBar("Notification"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Previously",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: NotifStyles.font,
              ),
            ),
            const SizedBox(height: 15),

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
            const Text(
              "A week ago",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: NotifStyles.font,
              ),
            ),
            const SizedBox(height: 15),

            const _NotificationCard(
              title: "AI Analysis Done",
              subtitle: "Your report has been categorized as 'Metal'.",
              time: "11:41am",
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.recycling, color: NotifStyles.headerTeal, size: 35),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                          color: Colors.black26,
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}