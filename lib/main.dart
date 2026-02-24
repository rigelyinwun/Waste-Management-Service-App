import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'firebase_options.dart';

import 'Admin/home.dart';
import 'Admin/dumping_stations.dart';
import 'Admin/reports.dart';
import 'Admin/locations.dart';
import 'Admin/dashboard.dart';
import 'Admin/waste_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/company',
      routes: {
        '/company': (context) => const AdminHomePage(),
        '/company/dumping-stations': (context) => const DumpingStationsPage(),
        '/company/reports': (context) => const ReportsPage(),
        '/company/waste-profile': (context) => const WasteProfilePage(),
        '/company/summary-dashboard': (context) => const SummaryDashboardPage(),
        '/company/locations': (context) => const LocationsPage(),
      },
    );
  }
}