import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class GlobalCSS {
  static const Color primaryGreen = Color(0xFF2E6153);
  static const Color mintBackground = Color(0xFFB5D9BC);
  static const Color fieldFill = Color(0xFF8BC9A8);
  static const Color darkBtn = Color(0xFF1B3022);
  static const String fontMain = 'LexendExa';
}

class LoginHeadingCSS {
  static const double titleSize = 58.0;
  static const double subtitleSize = 18.0;
}

class LoginFieldCSS {
  static const double borderRadius = 40.0;
  static const double verticalPadding = 20.0;
  static const double labelFontSize = 13.0;
}

class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstControl = Offset(size.width * 0.25, size.height * 0.7);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        firstControl.dx, firstControl.dy, firstEnd.dx, firstEnd.dy);

    var secondControl = Offset(size.width * 0.85, size.height * 0.95);
    var secondEnd = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(
        secondControl.dx, secondControl.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(old) => false;
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "LOGIN",
          style: TextStyle(
            fontFamily: GlobalCSS.fontMain,
            fontSize: LoginHeadingCSS.titleSize,
            fontWeight: FontWeight.w900,
            color: GlobalCSS.primaryGreen,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class LoginInputField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController controller;

  const LoginInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: GlobalCSS.primaryGreen,
                fontSize: LoginFieldCSS.labelFontSize,
              ),
            ),
          ),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: GlobalCSS.fieldFill,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 25, vertical: LoginFieldCSS.verticalPadding),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LoginFieldCSS.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithEmail(email: email, password: password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/base');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
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
    const Color highlightColor = Color(0xFF387664);

    return Scaffold(
      backgroundColor: GlobalCSS.mintBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(height: 400, color: GlobalCSS.mintBackground),
                ClipPath(
                  clipper: LoginWaveClipper(),
                  child: Container(
                    height: 340,
                    color: Colors.white,
                    child: const Center(child: LoginHeader()),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome back!\nSign in to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: GlobalCSS.fontMain,
                      fontSize: LoginHeadingCSS.subtitleSize,
                      fontWeight: FontWeight.bold,
                      color: GlobalCSS.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 40),
                  LoginInputField(
                    label: "EMAIL ADDRESS",
                    controller: _emailController,
                  ),
                  LoginInputField(
                    label: "PASSWORD",
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalCSS.darkBtn,
                      minimumSize: const Size(240, 58),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Log In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      // TODO: Add Forgot Password Logic
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: GlobalCSS.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: GlobalCSS.primaryGreen),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          "Sign Up!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: highlightColor,
                            fontSize: 18,
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
}