import 'package:flutter/material.dart';

class PrivacyStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB);
  static const String fontMain = 'LexendExa';
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivacyStyles.backgroundMint,
      appBar: AppBar(
        backgroundColor: PrivacyStyles.headerTeal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: PrivacyStyles.fontMain,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: PrivacyStyles.fontMain,
                color: PrivacyStyles.headerTeal,
              ),
            ),
            const SizedBox(height: 15),

            _buildSectionTitle("1. Information We Collect"),
            _buildBulletPoint("Account Data: We collect your name, email address, and password for account creation."),
            _buildBulletPoint("Business Data: For companies, we collect SSM Registration Numbers and company names to verify professional legitimacy."),
            _buildBulletPoint("Visual Data: Photos uploaded for waste reports are processed to identify waste types and quantities."),

            _buildSectionTitle("2. How We Use Your Data"),
            _buildBulletPoint("AI Analysis: Your images are processed by our AI to provide weight, cost estimates, and category matching."),
            _buildBulletPoint("Service Matching: Your data helps us match your waste reports with the most relevant recycling companies or volunteers in your area."),
            _buildBulletPoint("Communication: We use your email to send status updates regarding your collection requests."),

            _buildSectionTitle("3. Location Privacy"),
            _buildBulletPoint("Public View: Only a general neighborhood or district location is shown on the public map to maintain your privacy."),
            _buildBulletPoint("Pickup Reveal: Your exact address is only shared with a specific volunteer or business after you have approved their collection request."),

            _buildSectionTitle("4. Data Sharing & Third Parties"),
            _buildBulletPoint("Authorized Collectors: Information is shared only with the parties involved in your specific waste transaction."),
            _buildBulletPoint("No Commercial Selling: We do not sell your personal data, email, or habits to third-party advertisers or data brokers."),

            _buildSectionTitle("5. Security and Encryption"),
            _buildBulletPoint("We use industry-standard encryption to protect your sensitive information, including your password and business credentials."),
            _buildBulletPoint("Unauthorized access is prevented through secure server protocols and regular system audits."),

            _buildSectionTitle("6. User Rights & Data Retention"),
            _buildBulletPoint("Access & Edit: You can update your profile and business details at any time through the Edit Profile screen."),
            _buildBulletPoint("Account Deletion: You have the right to delete your account. Upon deletion, your personal identity data will be removed from our active systems."),

            _buildSectionTitle("7. Contact Us"),
            _buildSectionBody("If you have questions regarding your data or these policies, please contact our support team through the Help Center in the app settings."),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: PrivacyStyles.headerTeal,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: PrivacyStyles.headerTeal)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}