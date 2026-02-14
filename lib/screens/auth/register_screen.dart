import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;

  // Common controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // User fields
  final _usernameController = TextEditingController();

  // Company fields
  final _companyNameController = TextEditingController();
  final _ssmController = TextEditingController();
  final _wasteCategoriesController = TextEditingController(); // comma-separated
  final _serviceAreasController = TextEditingController(); // comma-separated

  bool isLoading = false;
  String selectedRole = 'user'; // default role

  void registerUser() async {
    setState(() => isLoading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      AppUser user;

      if (selectedRole == 'user') {
        user = AppUser(
          uid: cred.user!.uid,
          role: 'user',
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
        );
      } else {
        // company
        user = AppUser(
          uid: cred.user!.uid,
          role: 'company',
          email: _emailController.text.trim(),
          companyName: _companyNameController.text.trim(),
          companySSM: _ssmController.text.trim(),
          wasteCategories: _wasteCategoriesController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
          serviceAreas: _serviceAreasController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
        );
      }

      await UserService().createUserProfile(user);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration success!')));

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _roleSelection() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text('User'),
            leading: Radio<String>(
              value: 'user',
              groupValue: selectedRole,
              onChanged: (val) {
                setState(() => selectedRole = val!);
              },
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text('Company'),
            leading: Radio<String>(
              value: 'company',
              groupValue: selectedRole,
              onChanged: (val) {
                setState(() => selectedRole = val!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _dynamicFields() {
    if (selectedRole == 'user') {
      return TextField(
        controller: _usernameController,
        decoration: InputDecoration(labelText: 'Username'),
      );
    } else {
      return Column(
        children: [
          TextField(controller: _companyNameController, decoration: InputDecoration(labelText: 'Company Name')),
          TextField(controller: _ssmController, decoration: InputDecoration(labelText: 'SSM Number')),
          TextField(controller: _wasteCategoriesController, decoration: InputDecoration(labelText: 'Waste Categories (comma separated)')),
          TextField(controller: _serviceAreasController, decoration: InputDecoration(labelText: 'Service Areas (comma separated)')),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _roleSelection(),
            SizedBox(height: 10),
            _dynamicFields(),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              child: isLoading ? CircularProgressIndicator() : Text('Register'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}