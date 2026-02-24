import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Admin/dumping_stations.dart';
import 'Admin/reports.dart';
import 'Admin/dashboard.dart';
import 'Admin/waste_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskHomePage(),
      routes: {
        '/company/dumping-stations': (context) => const DumpingStationsPage(),//
        '/company/reports': (context) => const ReportsPage(),//
        '/company/waste-profile': (context) => const WasteProfilePage(),//
        '/company/summary-dashboard': (context) => const SummaryDashboardPage(),//
      },
    );
  }
}