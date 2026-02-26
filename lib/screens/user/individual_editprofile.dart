// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class EditProfileStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB);
  static const Color fieldGrey = Color(0xFFD9D9D9);
  static const Color fieldWhite = Colors.white;
  static const Color darkBtn = Color(0xFF1B3022);
  static const String font = 'LexendExa';

  static const TextStyle headerTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: font,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: font,
    color: headerTeal,
  );
}

class EditProfileIndividualPage extends StatelessWidget {
  const EditProfileIndividualPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditProfileStyles.backgroundMint,
      appBar: AppBar(
        backgroundColor: EditProfileStyles.headerTeal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile", style: EditProfileStyles.headerTextStyle),
      ),
      body: SingleChildScrollView(
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
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
              const Text("Your Information", style: EditProfileStyles.sectionTitleStyle),
              const SizedBox(height: 25),

              const _EditInfoField(hint: "Username", isWhite: true),
              const _EditInfoField(hint: "kingstom@gmail.com", isWhite: false), // Non-editable
              const _EditInfoField(hint: "123 4567", isWhite: true, isPhone: true),
              const _EditInfoField(hint: "Gender", isWhite: true),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Updated Successfully!")),
                    );
                  },
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          enabled: isWhite,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              color: isWhite ? Colors.black.withOpacity(0.3) : Colors.black45,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: isPhone
                ? Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("+60", style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
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