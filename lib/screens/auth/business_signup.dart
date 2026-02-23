import 'package:flutter/material.dart';
import 'login.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class BusinessSignUpPage extends StatefulWidget {
  const BusinessSignUpPage({super.key});

  @override
  State<BusinessSignUpPage> createState() => _BusinessSignUpPageState();
}

class _BusinessSignUpPageState extends State<BusinessSignUpPage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _ssmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isLoading = false;

  String? _selectedCategory;
  String? _selectedArea;

  final List<String> _categories = [
    "Metal",
    "Paper",
    "Plastic",
    "Glass",
    "E-Waste",
    "Fabric"
  ];
  final List<String> _areas = [
    "Kuala Lumpur",
    "Selangor",
    "Johor",
    "Penang",
    "Melaka",
    "Other"
  ];

  Future<void> _handleRegister() async {
    final companyName = _companyNameController.text.trim();
    final ssm = _ssmController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (companyName.isEmpty ||
        ssm.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedCategory == null ||
        _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.registerWithEmail(
          email: email, password: password);

      final newUser = AppUser(
        uid: userCredential.user!.uid,
        role: 'company',
        email: email,
        companyName: companyName,
        companySSM: ssm,
        wasteCategories: [_selectedCategory!],
        serviceAreas: [_selectedArea!],
      );

      await _userService.createUserProfile(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
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
                    "Business Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6153),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildField("COMPANY NAME", _companyNameController),
                  _buildField("COMPANY REGISTRATION (SSM)", _ssmController),
                  _buildField("BUSINESS EMAIL ADDRESS", _emailController),
                  _buildDropdown(
                      "WASTE CATEGORY:", _categories, _selectedCategory, (val) {
                    setState(() => _selectedCategory = val);
                  }),
                  _buildDropdown("SERVICE AREA", _areas, _selectedArea, (val) {
                    setState(() => _selectedArea = val);
                  }),
                  _buildField("PASSWORD", _passwordController, isObscure: true),
                  _buildField("CONFIRM PASSWORD", _confirmPasswordController,
                      isObscure: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      minimumSize: const Size(240, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already registered? ",
                        style: TextStyle(
                          color: Color(0xFF2E6153),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
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

  Widget _buildField(String label, TextEditingController controller,
      {bool isObscure = false}) {
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
            controller: controller,
            obscureText: isObscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF8BC9A8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
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

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
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
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            icon:
                const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF8BC9A8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
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
      onTap: () {},
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
          children: const [
            Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Text(
              "Sign in with Google",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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