import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'tnc.dart';
import 'signup.dart';
import 'login.dart';
import 'individual_signup.dart';
import 'business_signup.dart';
import 'homepage.dart';
import 'profilepage.dart';
import 'individual_editprofile.dart';
import 'business_editprofile.dart';
import 'privacypolicy.dart';
import 'rating.dart';
import 'feedback.dart';
import 'historyreport.dart';
import 'notification.dart';
import 'volunteercollected.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const TaskHomePage(),
      // These allow you to jump to these pages from anywhere in the app
      routes: {
        '/tnc': (context) => const TNCPage(),
        '/signup': (context) => SignUpPage(), // Remove 'const'
        '/login': (context) => const LoginPage(),
        '/individual_signup': (context) => const IndividualSignUpPage(),
        '/business_signup': (context) => const BusinessSignUpPage(),
        '/home': (context) => const TaskHomePage(),
        '/homepage': (context) => const HomePage(),
        '/profilepage': (context) => const ProfilePage(),
        '/individual_editprofile': (context) => const EditProfileIndividualPage(),
        '/business_editprofile': (context) => const EditProfileBusinessPage(),
        '/privatepolicy': (context) => const PrivacyPolicyPage(),
        '/rating': (context) => const RatingPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/notification': (context) => const NotificationPage(),
        '/historyreport': (context) => HistoryReportPage(),
        '/volunteercollected': (context) => VolunteerCollectedPage(
          report: ModalRoute.of(context)!.settings.arguments as WasteReport,
        ),
      },
    );
  }
}