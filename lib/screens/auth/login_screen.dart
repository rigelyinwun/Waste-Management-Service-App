import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  AppUser? loggedInUser;

  void loginUser() async {
    setState(() => isLoading = true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = await UserService().fetchUserProfile(cred.user!.uid);

      setState(() => loggedInUser = user);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Welcome ${user?.username ?? 'User'}')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void signOutUser() async {
    await _auth.signOut();
    setState(() {
      loggedInUser = null;
      _emailController.clear();
      _passwordController.clear();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Signed out successfully')));
  }

  void editUserInfo() async {
    if (loggedInUser == null) return;

    final usernameController = TextEditingController(text: loggedInUser!.username);
    final emailController = TextEditingController(text: loggedInUser!.email);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = AppUser(
                uid: loggedInUser!.uid,
                role: loggedInUser!.role,
                username: usernameController.text.trim(),
                email: emailController.text.trim(),
                companyName: loggedInUser!.companyName,
                serviceAreas: loggedInUser!.serviceAreas,
                wasteCategories: loggedInUser!.wasteCategories,
              );

              await UserService().updateUserProfile(loggedInUser!.uid, updatedUser.toMap());

              setState(() => loggedInUser = updatedUser);

              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Info updated')));
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  Widget _userInfoWidget() {
    if (loggedInUser == null) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Info:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('UID: ${loggedInUser!.uid}'),
            Text('Role: ${loggedInUser!.role}'),
            Text('Username: ${loggedInUser!.username ?? '-'}'),
            Text('Email: ${loggedInUser!.email ?? '-'}'),
            if (loggedInUser!.companyName != null)
              Text('Company: ${loggedInUser!.companyName}'),
            if (loggedInUser!.serviceAreas != null)
              Text('Service Areas: ${loggedInUser!.serviceAreas?.join(', ')}'),
            if (loggedInUser!.wasteCategories != null)
              Text('Waste Categories: ${loggedInUser!.wasteCategories?.join(', ')}'),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(onPressed: editUserInfo, child: Text('Edit Info')),
                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/report');
                  },
                  child: Text('Report'),
                ),

                SizedBox(width: 10),
                ElevatedButton(onPressed: signOutUser, child: Text('Sign Out')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isLoading ? null : loginUser,
                child: isLoading ? CircularProgressIndicator() : Text('Login')),
            TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Go to Register')),
            _userInfoWidget(),
          ],
        ),
      ),
    );
  }
}