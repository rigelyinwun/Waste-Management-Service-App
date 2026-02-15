import 'package:flutter/material.dart';

// =============================================================================
// SECTION 1: STYLE DEFINITIONS
// =============================================================================
class RatingStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color textGreen = Color(0xFF388E3C);
  static const Color textGrey = Color(0xFFAAAAAA);
  static const String fontMain = 'LexendExa';
}

// =============================================================================
// SECTION 2: THE RATING PAGE
// =============================================================================
class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _currentRating = 0; // Tracks the selected star

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RatingStyles.backgroundMint,
      // --- Teal Header matching your design ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: RatingStyles.headerTeal,
          padding: const EdgeInsets.only(top: 40, left: 10),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Rating This App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: RatingStyles.fontMain,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🚀", style: TextStyle(fontSize: 60)), // Simplified for code, replace with Image if needed
                const SizedBox(height: 20),

                const Text(
                  "Enjoying the App?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RatingStyles.textGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: RatingStyles.fontMain,
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Your feedback helps us create a cleaner environmental",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RatingStyles.textGrey,
                    fontSize: 12,
                    fontFamily: RatingStyles.fontMain,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Star Rating System ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _currentRating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: index < _currentRating ? Colors.amber : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentRating = index + 1;
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: 10),
                const Text(
                  "Tap to rate",
                  style: TextStyle(
                    color: RatingStyles.textGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: RatingStyles.fontMain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}