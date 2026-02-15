import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'base.dart';
import 'homepage.dart';
import 'historyreport.dart';
import 'notification.dart';
import 'profilepage.dart';
import 'volunteercollected.dart';
import 'login.dart';
import 'signup.dart';
import 'tnc.dart';
import 'individual_signup.dart';
import 'business_signup.dart';
import 'individual_editprofile.dart';
import 'business_editprofile.dart';
import 'privacypolicy.dart';
import 'rating.dart';
import 'feedback.dart';
import 'reportwaste.dart';
import 'successpage.dart';
import 'report_result.dart';
import 'wastelist.dart';

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
      home: const LoginPage(),
      routes: {
        '/tnc': (context) => const TNCPage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/individual_signup': (context) => const IndividualSignUpPage(),
        '/business_signup': (context) => const BusinessSignUpPage(),
        '/homepage': (context) => const HomePage(),
        '/profilepage': (context) => const ProfilePage(),
        '/individual_editprofile': (context) => const EditProfileIndividualPage(),
        '/business_editprofile': (context) => const EditProfileBusinessPage(),
        '/privatepolicy': (context) => const PrivacyPolicyPage(),
        '/rating': (context) => const RatingPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/reportwaste': (context) => const ReportPage(),
        '/notification': (context) => const NotificationPage(),
        '/historyreport': (context) => const HistoryReportPage(),
        '/base': (context) => const MainBasePage(),
        '/successpage': (context) => const SubmissionSuccessPage(),
        '/report_result': (context) => const ReportResultPage(),
        '/wastelist': (context) => const WasteListPage(),
        '/volunteercollected': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args != null) {
            return VolunteerCollectedPage(report: args as dynamic);
          }
          return const Scaffold(body: Center(child: Text("Error: No Report Data")));
        },
      },
    );
  }
}