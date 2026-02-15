import 'package:flutter/material.dart';
import 'login.dart';

class BusinessSignUpPage extends StatelessWidget {
  const BusinessSignUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFB7D7C0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: SyntheticCurveClipper(),
                  child: Container(
                    height: size.height * 0.4,
                    color: Colors.white,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E6153),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            print("Triggering Google Sign-In...");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.black12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.account_circle, color: Colors.red),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Sign in with Google",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const Text(
                    "Already registered?\nLog in here",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E6153)),
                  ),
                  const SizedBox(height: 30),
                  _buildField("COMPANY NAME"),
                  _buildField("COMPANY REGISTRATION (SSM)"),
                  _buildField("BUSINESS EMAIL ADDRESS"),
                  _buildField("Waste Category:", isDropdown: true),
                  _buildField("Service Area", isDropdown: true),
                  _buildField("PASSWORD"),
                  _buildField("Confirm Password"),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      minimumSize: const Size(240, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, {bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E6153)),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF8BC9A8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: BorderSide.none),
              suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class SyntheticCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.55);
    var controlPoint = Offset(size.width * 0.45, size.height * 1.1);
    var endPoint = Offset(size.width, size.height * 0.90);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
