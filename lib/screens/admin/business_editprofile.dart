import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class BusinessEditStyles {
  // ... (keeping existing styles)
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color fieldGrey = Color(0xFFD9D9D9);
  static const Color fieldWhite = Colors.white;
  static const Color darkBtn = Color(0xFF1B3022);
  static const String font = 'LexendExa';
  static const TextStyle headerText = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: font,
  );
}

class EditProfileBusinessPage extends StatefulWidget {
  const EditProfileBusinessPage({super.key});
  @override
  State<EditProfileBusinessPage> createState() => _EditProfileBusinessPageState();
}

class _EditProfileBusinessPageState extends State<EditProfileBusinessPage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ssmController = TextEditingController();

  List<String> selectedCategories = [];
  String? selectedArea;
  bool _isLoading = false;

  final List<String> wasteCategories = ["Metal", "Paper", "Plastic", "Glass", "E-Waste", "Fabric"];
  final List<String> serviceAreas = ["Kuala Lumpur", "Selangor", "Johor", "Penang", "Melaka", "Other"];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final profile = await _userService.fetchUserProfile(user.uid);
      if (profile != null) {
        setState(() {
          _companyNameController.text = profile.companyName ?? "";
          _emailController.text = profile.email;
          _phoneController.text = profile.phoneNumber ?? "";
          _ssmController.text = profile.companySSM ?? "";
          selectedCategories = profile.wasteCategories ?? [];
          selectedArea = profile.serviceAreas?.isNotEmpty == true ? profile.serviceAreas![0] : null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final updates = {
        'companyName': _companyNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'companySSM': _ssmController.text.trim(),
        'wasteCategories': selectedCategories,
        'serviceAreas': selectedArea != null ? [selectedArea!] : [],
      };

      await _userService.updateUserProfile(user.uid, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessEditStyles.backgroundMint,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: BusinessEditStyles.headerTeal,
          padding: const EdgeInsets.only(top: 40, left: 10),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Image.asset('assets/logo.png', width: 30, height: 30),
              const SizedBox(width: 10),
              const Text("Edit Profile", style: BusinessEditStyles.headerText),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: BusinessEditStyles.headerTeal))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(radius: 70, backgroundColor: Colors.grey.shade300),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text("Your Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    _BusinessField(hint: "Company Name", isWhite: true, controller: _companyNameController),
                    _BusinessField(hint: "Email", isWhite: false, controller: _emailController),
                    _BusinessField(hint: "Phone Number", isWhite: true, isPhone: true, controller: _phoneController),
                    _BusinessField(hint: "Business Registration (SSM)", isWhite: true, controller: _ssmController),
                    _buildMultiSelectField("Waste Category", wasteCategories),
                    const SizedBox(height: 15),
                    _buildDropdownField("Service Area", serviceAreas, selectedArea, (val) {
                      setState(() => selectedArea = val);
                    }),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BusinessEditStyles.darkBtn,
                          minimumSize: const Size(220, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMultiSelectField(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: items.map((category) {
              final isSelected = selectedCategories.contains(category);
              return FilterChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                  });
                },
                selectedColor: BusinessEditStyles.darkBtn,
                checkmarkColor: Colors.white,
                backgroundColor: BusinessEditStyles.backgroundMint,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String hint, List<String> items, String? currentVal, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            initialValue: currentVal,
            hint: Text(hint, style: TextStyle(color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.bold)),
            decoration: const InputDecoration(border: InputBorder.none),
            items: items.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _BusinessField extends StatelessWidget {
  final String hint;
  final bool isWhite;
  final bool isPhone;
  final TextEditingController? controller;
  const _BusinessField({required this.hint, required this.isWhite, this.isPhone = false, this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isWhite ? BusinessEditStyles.fieldWhite : BusinessEditStyles.fieldGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          enabled: isWhite,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.bold),
            prefixIcon: isPhone ? const _PhonePrefix() : null,
          ),
        ),
      ),
    );
  }
}

class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Row(
        children: const [
          Text("+60", style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
          Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
    );
  }
}