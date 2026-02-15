import 'package:flutter/material.dart';

class BusinessEditStyles {
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
  // Dropdown values
  String? selectedCategory;
  String? selectedArea;

  final List<String> wasteCategories = ["Fabric", "Furniture", "Metal", "Plastic", "Electronic"];
  final List<String> serviceAreas = ["Kuala Lumpur", "Johor Bahru", "Penang", "Melaka", "Ipoh"];

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
              const Text("Edit Profile", style: BusinessEditStyles.headerText),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // --- Avatar Section ---
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

              // --- Text Fields ---
              const _BusinessField(hint: "Company Name", isWhite: true),
              const _BusinessField(hint: "business@gmail.com", isWhite: false),
              const _BusinessField(hint: "123 1232", isWhite: true, isPhone: true),
              const _BusinessField(hint: "Business Registration (SSM)", isWhite: true),

              // --- Dropdown Fields ---
              _buildDropdownField("Waste Category", wasteCategories, selectedCategory, (val) {
                setState(() => selectedCategory = val);
              }),
              _buildDropdownField("Service Area", serviceAreas, selectedArea, (val) {
                setState(() => selectedArea = val);
              }),

              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

  // Dropdown Builder
  Widget _buildDropdownField(String hint, List<String> items, String? currentVal, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            value: currentVal,
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

// Reusable Text Field
class _BusinessField extends StatelessWidget {
  final String hint;
  final bool isWhite;
  final bool isPhone;

  const _BusinessField({required this.hint, required this.isWhite, this.isPhone = false});

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