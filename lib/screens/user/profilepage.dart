import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class ProfileStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB);
  static const Color editBtnGreen = Color(0xFF4FD195);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const String font = 'LexendExa';
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  AppUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final user = await _userService.fetchUserProfile(currentUser.uid);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  PreferredSizeWidget _buildAppBar(String title) => AppBar(
        backgroundColor: ProfileStyles.headerTeal,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child: const Text(
                  "Confirmation Box",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.error_outline, size: 80, color: Colors.grey),
            ],
          ),
          titlePadding: EdgeInsets.zero,
          content: const Text(
            "Are you sure you want to\nlog out?",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dialogButton("Yes", () async {
                    await _authService.logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  }),
                  const SizedBox(width: 20),
                  _dialogButton("No", () => Navigator.pop(context)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogButton(String text, VoidCallback onTap) => SizedBox(
        width: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB0B0B0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onTap,
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileStyles.backgroundMint,
      appBar: _buildAppBar("My Profile"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
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
                          child: const Icon(Icons.person,
                              size: 50, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user?.username ?? "User",
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _user?.email ?? "email@example.com",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/individual_editprofile'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ProfileStyles.editBtnGreen,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Edit Profile",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
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
                    child: Text("General Settings",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  // Settings List
                  const SettingsTile(
                    icon: Icons.wb_sunny_outlined,
                    title: "Mode",
                    subtitle: "Dark & Light",
                    hasSwitch: true,
                  ),
                  SettingsTile(
                      icon: Icons.language, title: "Language", onTap: () {}),
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
                  SettingsTile(
                    icon: Icons.star_outline,
                    title: "Rating This App",
                    onTap: () => Navigator.pushNamed(context, '/rating'),
                  ),
                  SettingsTile(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}

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
          ? Text(subtitle!,
              style: TextStyle(color: Colors.green.shade700, fontSize: 11))
          : null,
      trailing: hasSwitch
          ? Switch(
              value: false,
              onChanged: (v) {},
              activeColor: ProfileStyles.headerTeal)
          : const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 16),
      onTap: onTap,
    );
  }
}