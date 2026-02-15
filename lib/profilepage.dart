import 'package:flutter/material.dart';

// =============================================================================
// SECTION 1: STYLE DEFINITIONS (Matching your design palette)
// =============================================================================
class ProfileStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color editBtnGreen = Color(0xFF4FD195);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const String font = 'LexendExa';
}

// =============================================================================
// SECTION 2: THE PROFILE PAGE
// =============================================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileStyles.backgroundMint,
      // --- Custom Teal Header ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: ProfileStyles.headerTeal,
          padding: const EdgeInsets.only(top: 40, left: 20),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: ProfileStyles.font,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // --- User Info Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  // Circular Profile Placeholder
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kingstom",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: ProfileStyles.font,
                          ),
                        ),
                        Text(
                          "kingstom@gmail.com",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProfileStyles.editBtnGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text(
                "General Settings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: ProfileStyles.font,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Settings List ---
            const SettingsTile(
              icon: Icons.wb_sunny_outlined,
              title: "Mode",
              subtitle: "Dark & Light",
              hasSwitch: true,
            ),
            const SettingsTile(icon: Icons.language, title: "Language"),
            const SettingsTile(icon: Icons.history_edu, title: "History Report"),
            const SettingsTile(icon: Icons.book_outlined, title: "Terms & Conditions"),
            const SettingsTile(icon: Icons.lock_outline, title: "Privacy Policy"),
            const SettingsTile(icon: Icons.stars_outlined, title: "Rate This App"),

            const SizedBox(height: 50),
          ],
        ),
      ),

      // Reuse your existing Bottom Bar here
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4, // Profile tab active
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 3: REUSABLE SETTINGS TILE
// =============================================================================
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool hasSwitch;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.hasSwitch = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Icon(icon, color: Colors.black, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.pink.shade100, fontSize: 12))
          : null,
      trailing: hasSwitch
          ? Switch(value: false, onChanged: (v) {}, activeColor: Colors.black)
          : const Icon(Icons.arrow_forward, color: Colors.black),
      onTap: () {},
    );
  }
}