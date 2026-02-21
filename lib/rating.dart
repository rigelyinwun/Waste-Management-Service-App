import 'package:flutter/material.dart';

class RatingStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB); // Updated to your specific green
  static const Color textGreen = Color(0xFF388E3C);
  static const Color textGrey = Color(0xFFAAAAAA);
  static const String fontMain = 'LexendExa';
}

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _currentRating = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RatingStyles.backgroundMint,
      appBar: AppBar(
        backgroundColor: RatingStyles.headerTeal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rating This App",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: RatingStyles.fontMain,
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
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🚀", style: TextStyle(fontSize: 60)),
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
                  "Your feedback helps us create a cleaner environment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RatingStyles.textGrey,
                    fontSize: 12,
                    fontFamily: RatingStyles.fontMain,
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _currentRating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: index < _currentRating ? Colors.amber : Colors.black26,
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

                if (_currentRating > 0) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RatingStyles.headerTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Submit"),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}