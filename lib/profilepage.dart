import 'package:flutter/material.dart';

// =============================================================================
// SECTION 1: STYLE DEFINITIONS
// =============================================================================
class ProfileStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color editBtnGreen = Color(0xFF4FD195);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const String font = 'LexendExa';
}

// =============================================================================
// SECTION 2: THE PROFILE PAGE (Content Only)
// =============================================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold, AppBar, and BottomNav because MainBasePage provides them.
    return Container(
      color: ProfileStyles.backgroundMint,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title (Replaces the AppBar text)
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 30, 25, 10),
              child: Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: ProfileStyles.headerTeal,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profile Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "kingstom@gmail.com",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Edit Profile Button
                        SizedBox(
                          height: 35,
                          child: ElevatedButton(
                            onPressed: () {
                              // Link to your edit profile route
                              Navigator.pushNamed(context, '/individual_editprofile');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProfileStyles.editBtnGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Settings List ---
            const SettingsTile(
              icon: Icons.wb_sunny_outlined,
              title: "Mode",
              subtitle: "Dark & Light",
              hasSwitch: true,
            ),
            SettingsTile(
              icon: Icons.language,
              title: "Language",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.history_edu,
              title: "History Report",
              onTap: () => Navigator.pushNamed(context, '/historyreport'),
            ),
            SettingsTile(
              icon: Icons.book_outlined,
              title: "Terms & Conditions",
              onTap: () => Navigator.pushNamed(context, '/tnc'),
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              title: "Privacy Policy",
              onTap: () => Navigator.pushNamed(context, '/privatepolicy'),
            ),
            const SettingsTile(icon: Icons.stars_outlined, title: "Rate This App"),

            // Logout Option
            SettingsTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),

            const SizedBox(height: 100), // Extra padding for bottom nav
          ],
        ),
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
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.hasSwitch = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
      leading: Icon(icon, color: ProfileStyles.headerTeal, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.green.shade700, fontSize: 11))
          : null,
      trailing: hasSwitch
          ? Switch(value: false, onChanged: (v) {}, activeColor: ProfileStyles.headerTeal)
          : const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 16),
      onTap: onTap,
    );
  }
}