import 'package:flutter/material.dart';

class TNCPage extends StatelessWidget {
  const TNCPage({super.key});
  @override
  Widget build(BuildContext context) {
    const Color headerTeal = Color(0xFF387664);
    const Color backgroundMint = Color(0xFFD3E6DB);
    return Scaffold(
      backgroundColor: backgroundMint,
      appBar: AppBar(
        backgroundColor: headerTeal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Terms and Conditions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SmartWaste Policies",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: headerTeal),
            ),
            const SizedBox(height: 15),

            _buildSectionTitle("1. Acceptance of Terms"),
            _buildSectionBody("By registering, logging in, or using any feature of the Platform, you confirm that you have read, understood, and agreed to these Terms & Conditions."),

            _buildSectionTitle("2. User Eligibility"),
            _buildBulletPoint("Users must provide accurate and complete information during registration."),
            _buildBulletPoint("You are responsible for maintaining the confidentiality of your login credentials."),
            _buildBulletPoint("Any activity under your account is your responsibility."),

            _buildSectionTitle("3. User Responsibilities"),
            _buildSectionBody("Users agree to:"),
            _buildBulletPoint("Submit truthful and accurate waste reports, including images, descriptions, and locations."),
            _buildBulletPoint("Report only legitimate household or public waste."),
            _buildBulletPoint("Avoid uploading harmful, misleading, illegal, or offensive content."),
            _buildBulletPoint("Use the Platform strictly for its intended purpose."),

            _buildSectionTitle("4. Waste Reporting & Collection"),
            _buildBulletPoint("Reported waste information may be shared with relevant waste management companies or volunteers."),
            _buildBulletPoint("If a report is marked as “Allow Public Collection”, volunteers may request to collect the waste."),
            _buildBulletPoint("The real address of the requester will only be revealed after confirmation and user consent."),
            _buildBulletPoint("Collection timelines are estimates and not guaranteed."),

            _buildSectionTitle("5. Volunteer & Company Participation"),
            _buildBulletPoint("Volunteers and registered companies are responsible for handling waste according to local regulations."),
            _buildBulletPoint("The Platform acts only as a matching and coordination system and does not guarantee service quality."),
            _buildBulletPoint("Any dispute between users, volunteers, or companies must be resolved independently."),

            _buildSectionTitle("6. Company Matching and Services"),
            _buildBulletPoint("6.1 Capabilities: Companies can view relevant reports and accept/reject collection requests."),
            _buildBulletPoint("6.2 Limitations: The Platform does not guarantee company availability, response time, or service quality."),
            _buildBulletPoint("6.3 Independence: Any agreement between users and companies is independent of the Platform."),

            _buildSectionTitle("7. AI-Generated Analysis"),
            _buildBulletPoint("7.1 Purpose: AI generates category suggestions, weight/cost estimates, and company recommendations."),
            _buildBulletPoint("7.2 Accuracy: AI outputs are for informational purposes and are not guaranteed to be accurate."),
            _buildBulletPoint("7.3 Liability: The Platform shall not be held liable for decisions made based on AI-generated data."),

            _buildSectionTitle("8. Privacy & Data Protection"),
            _buildBulletPoint("We collect and process personal data (Name, Email, Location) to facilitate waste collection services."),
            _buildBulletPoint("Images uploaded are used for AI processing and service verification."),
            _buildBulletPoint("We do not sell your personal data to third parties for marketing purposes."),

            _buildSectionTitle("9. Account Termination"),
            _buildBulletPoint("The Platform reserves the right to suspend or terminate accounts that violate these terms."),
            _buildBulletPoint("Users may delete their accounts at any time, though historical report data may be retained for record-keeping."),

            _buildSectionTitle("10. Amendments to Terms"),
            _buildBulletPoint("We may update these Terms & Conditions from time to time to reflect changes in our services or laws."),
            _buildBulletPoint("Continued use of the Platform after updates constitutes acceptance of the new terms."),

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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF387664)),
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
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664))),
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