// import 'package:flutter/material.dart';
//
// // =============================================================================
// // SECTION 1: STYLES (Matching your Mint Theme)
// // =============================================================================
// class BusinessStyles {
//   static const Color textGreen = Color(0xFF2E6153);
//   static const Color mintBg = Color(0xFFB7D7C0); // Same as Join Us page
//   static const Color fieldFill = Color(0xFF8BC9A8);
//   static const Color darkBtn = Color(0xFF1B3022);
//
//   static const TextStyle titleStyle = TextStyle(
//     fontSize: 50,
//     fontWeight: FontWeight.w900,
//     color: textGreen,
//   );
//
//   static const TextStyle labelStyle = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.bold,
//     color: textGreen,
//   );
//
//   static InputDecoration fieldDecoration = InputDecoration(
//     filled: true,
//     fillColor: fieldFill,
//     contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(40),
//       borderSide: BorderSide.none,
//     ),
//   );
// }
//
// // =============================================================================
// // SECTION 2: THE MAIN PAGE
// // =============================================================================
// class BusinessSignUpPage extends StatelessWidget {
//   const BusinessSignUpPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: BusinessStyles.mintBg,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // --- HEADER: LEFT HIGH, RIGHT LOW (Matching Join Us Page) ---
//             Stack(
//               children: [
//                 ClipPath(
//                   clipper: SyntheticCurveClipper(),
//                   child: Container(
//                     height: size.height * 0.4,
//                     color: Colors.white,
//                     width: double.infinity,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("Sign Up", style: BusinessStyles.titleStyle),
//                         const SizedBox(height: 10),
//                         _buildGoogleBtn(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             // --- FORM CONTENT ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Already registered?\nLog in here",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: BusinessStyles.textGreen,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   const BusinessInputField(label: "COMPANY NAME"),
//                   const BusinessInputField(label: "COMPANY REGISTRATION (SSM)"),
//                   const BusinessInputField(label: "BUSINESS EMAIL ADDRESS"),
//                   const BusinessInputField(label: "Waste Category:", isDropdown: true),
//                   const BusinessInputField(label: "Service Area", isDropdown: true),
//                   const BusinessInputField(label: "PASSWORD"),
//                   const BusinessInputField(label: "Confirm Password"),
//                   const SizedBox(height: 30),
//                   _buildSubmitBtn(),
//                   const SizedBox(height: 50),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGoogleBtn() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(color: Colors.black12),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: const [
//           Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
//           SizedBox(width: 5),
//           Text("Signin with Google", style: TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSubmitBtn() {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: BusinessStyles.darkBtn,
//         minimumSize: const Size(240, 55),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: () {},
//       child: const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//     );
//   }
// }
//
// // =============================================================================
// // SECTION 3: COMPONENTS
// // =============================================================================
//
// class BusinessInputField extends StatelessWidget {
//   final String label;
//   final bool isDropdown;
//   const BusinessInputField({super.key, required this.label, this.isDropdown = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 15, bottom: 5),
//             child: Text(label, style: BusinessStyles.labelStyle),
//           ),
//           TextField(
//             decoration: BusinessStyles.fieldDecoration.copyWith(
//               suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30) : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // --- CLIPPER: THE EXACT ANGLE FROM JOIN US PAGE ---
// class SyntheticCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//
//     // 1. Start High on Left (55% of container height)
//     path.lineTo(0, size.height * 0.55);
//
//     // 2. Control point creates a single deep sweep
//     // 3. End point is Low on Right (90% of container height)
//     var controlPoint = Offset(size.width * 0.45, size.height * 1.1);
//     var endPoint = Offset(size.width, size.height * 0.90);
//
//     path.quadraticBezierTo(
//         controlPoint.dx,
//         controlPoint.dy,
//         endPoint.dx,
//         endPoint.dy
//     );
//
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }

import 'package:flutter/material.dart';
import 'login.dart'; // Make sure you have your LoginPage defined here

class BusinessSignUpPage extends StatelessWidget {
  const BusinessSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFB7D7C0), // Mint Background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
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
                        // GOOGLE BUTTON (dummy for now)
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

            // --- FORM FIELDS ---
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

                  // LOG IN BUTTON -> Navigate to LoginPage
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      minimumSize: const Size(240, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Navigate to LoginPage
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

// --- CLIPPER ---
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
