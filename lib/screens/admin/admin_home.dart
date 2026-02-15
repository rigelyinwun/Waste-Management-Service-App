import 'package:flutter/material.dart';
import 'dumping_station.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartWaste Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Go To Dumping Stations'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DumpingStationScreen(companyId: FirebaseAuth.instance.currentUser!.uid),
              ),
            );
          },
        ),
      ),
    );
  }
}