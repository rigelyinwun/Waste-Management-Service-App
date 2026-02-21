import 'package:flutter/material.dart';
import 'login.dart';

class IndividualSignUpPage extends StatefulWidget {
  const IndividualSignUpPage({super.key});

  @override
  State<IndividualSignUpPage> createState() => _IndividualSignUpPageState();
}

class _IndividualSignUpPageState extends State<IndividualSignUpPage> {
  String? _selectedLocation;
  final List<String> _locations = [
    "Kuala Lumpur",
    "Selangor",
    "Johor",
    "Penang",
    "Melaka",
    "Sabah",
    "Sarawak"
  ];

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
                        const SizedBox(height: 10),
                        _buildGoogleBtn(context),
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
                    "Personal Account\nJoin the movement",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6153),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildField("FULL NAME"),
                  _buildField("EMAIL ADDRESS"),
                  _buildField("PHONE NUMBER"),
                  _buildDropdown("LOCATION/CITY", _locations, _selectedLocation, (val) {
                    setState(() => _selectedLocation = val);
                  }),
                  _buildField("PASSWORD", isObscure: true),
                  _buildField("CONFIRM PASSWORD", isObscure: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      minimumSize: const Size(240, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Color(0xFF2E6153),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Log In here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E6153),
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildField(String label, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E6153),
              ),
            ),
          ),
          TextField(
            obscureText: isObscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF8BC9A8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E6153),
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedValue,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF8BC9A8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleBtn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
            SizedBox(width: 5),
            const Text("Signin with Google",
                style: TextStyle(fontWeight: FontWeight.w600)),
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
    path.lineTo(0, size.height * 0.55);
    var controlPoint = Offset(size.width * 0.45, size.height * 1.1);
    var endPoint = Offset(size.width, size.height * 0.90);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}