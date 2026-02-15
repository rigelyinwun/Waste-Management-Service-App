import 'package:flutter/material.dart';

// =============================================================================
// SECTION 1: THE "CSS" LAYER (Embedded Styles)
// =============================================================================
class EditProfileStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color fieldGrey = Color(0xFFD9D9D9);
  static const Color fieldWhite = Colors.white;
  static const Color darkBtn = Color(0xFF1B3022);
  static const String font = 'LexendExa';

  static const TextStyle headerTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: font,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: font,
  );
}

// =============================================================================
// SECTION 2: THE PAGE COMPONENT
// =============================================================================
class EditProfileIndividualPage extends StatelessWidget {
  const EditProfileIndividualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditProfileStyles.backgroundMint,
      // Custom AppBar matching Design
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: EditProfileStyles.headerTeal,
          padding: const EdgeInsets.only(top: 40, left: 10),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text("Edit Profile", style: EditProfileStyles.headerTextStyle),
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

              // --- Avatar Section with Camera Icon Overlay ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
              const Text("Your Information", style: EditProfileStyles.sectionTitleStyle),
              const SizedBox(height: 25),

              const _EditInfoField(hint: "Username", isWhite: true),
              const _EditInfoField(hint: "kingstom@gmail.com", isWhite: false), // Non-editable
              const _EditInfoField(hint: "123 1232", isWhite: true, isPhone: true),
              const _EditInfoField(hint: "Gender", isWhite: true),

              const SizedBox(height: 40),

              // --- Save Button ---
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EditProfileStyles.darkBtn,
                    minimumSize: const Size(220, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 3: REUSABLE HELPER WIDGETS
// =============================================================================
class _EditInfoField extends StatelessWidget {
  final String hint;
  final bool isWhite;
  final bool isPhone;

  const _EditInfoField({
    required this.hint,
    required this.isWhite,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isWhite ? EditProfileStyles.fieldWhite : EditProfileStyles.fieldGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          enabled: isWhite,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.3),
              fontWeight: FontWeight.bold,
            ),
            // Handles the phone dropdown design from screenshot
            prefixIcon: isPhone
                ? Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("+60", style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_drop_down, color: Colors.black54),
                ],
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }
}