import 'package:flutter/material.dart';

// =============================================================================
// SECTION 1: STYLE DEFINITIONS
// =============================================================================
class FeedbackStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color fieldMint = Color(0xFFF1F8F5);
  static const Color starBoxTeal = Color(0xFF387664);
  static const String font = 'LexendExa';
}

// =============================================================================
// SECTION 2: THE FEEDBACK PAGE
// =============================================================================
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeedbackStyles.backgroundMint,
      // --- Header matching your other pages ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: FeedbackStyles.headerTeal,
          padding: const EdgeInsets.only(top: 40, left: 10),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Feedback",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: FeedbackStyles.font,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Stack(
              children: [
                // --- Quotation Mark Icon (Top Right) ---
                const Positioned(
                  top: -10,
                  right: 0,
                  child: Text(
                    '“',
                    style: TextStyle(
                      fontSize: 100,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speaker_notes_outlined, size: 60, color: Colors.black),
                    const SizedBox(height: 15),
                    const Text(
                      "Your Feedback",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Your dedication to our service is commendable.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 30),

                    // --- Interactive Star Rating Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedStars = index + 1),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: index < selectedStars
                                  ? FeedbackStyles.starBoxTeal
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.star, color: Colors.white, size: 28),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),

                    // --- Description Input Field ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: FeedbackStyles.fieldMint,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Type something here...",
                          hintStyle: TextStyle(color: Colors.black26),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Submit Button ---
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FeedbackStyles.headerTeal,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}