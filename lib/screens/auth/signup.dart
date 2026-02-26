// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
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
  final UserService _userService = UserService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        // We don't check for profile here, because they might be choosing role now
        // But if they already HAVE a profile, we should just log them in
        final userProfile = await _userService.fetchUserProfile(userCredential.user!.uid);
        if (userProfile != null) {
          final role = userProfile.role.toLowerCase();
          if (role == 'admin' || role == 'company' || role == 'business') {
            Navigator.pushReplacementNamed(context, '/admin_base');
          } else {
            Navigator.pushReplacementNamed(context, '/base');
          }
          return;
        }

        // Stay on this page but now they choose role to complete signup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google account linked. Now select your account type.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google signup failed: ${e.toString()}")),
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
                  if (!isGoogleSignedIn) 
                    _GoogleSignUpButton(
                      isLoading: _isLoading,
                      onPressed: _handleGoogleSignUp,
                    ),
                  if (isGoogleSignedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Signed in as ${googleUser.email}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F)),
                          ),
                        ],
                      ),
                    ),
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

class _GoogleSignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignUpButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(240, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFF2D6A4F)),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red),
                ),
                const SizedBox(width: 10),
                const Text("Continue with Google", style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)),
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