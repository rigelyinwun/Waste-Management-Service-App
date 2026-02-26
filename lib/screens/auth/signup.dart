// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'individual_signup.dart';
import 'business_signup.dart';
// For GlobalCSS

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    // Check if user is already signed in with Google but needs to choose role
    final googleUser = _authService.currentUser;
    final bool isGoogleSignedIn = googleUser != null && googleUser.providerData.any((p) => p.providerId == 'google.com');

    return Scaffold(
      backgroundColor: const Color(0xFFB7D7C0),
      body: Stack(
        children: [
          ClipPath(
            clipper: SyntheticCurveClipper(),
            child: Container(
              height: size.height * 0.45,
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.recycling, size: 80, color: Color(0xFF2D6A4F)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'JOIN US',
                    style: TextStyle(
                      fontSize: isMobile ? 42 : 65,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D6A4F),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tell Us Who You Are',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 24,
                      color: const Color(0xFF2D6A4F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),

          SizedBox.expand(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.42),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isMobile ? 600 : 1000),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _BigSelectionCard(
                                title: 'Individual',
                                subtitle: 'Households clearing clutter',
                                icon: Icons.home_outlined,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => IndividualSignUpPage(
                                      isGoogle: isGoogleSignedIn,
                                      googleEmail: googleUser?.email,
                                      googleName: googleUser?.displayName,
                                    )
                                  )
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _BigSelectionCard(
                                title: 'Business',
                                subtitle: 'Licensed collectors & recyclers',
                                icon: Icons.business_outlined,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => BusinessSignUpPage(
                                      isGoogle: isGoogleSignedIn,
                                      googleEmail: googleUser?.email,
                                      googleName: googleUser?.displayName,
                                    )
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BigSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F)),
            ),
            const SizedBox(height: 25),
            Icon(icon, size: 85, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 25),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class SyntheticCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.5);
    var controlPoint = Offset(size.width * 0.45, size.height * 1.0);
    var endPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}