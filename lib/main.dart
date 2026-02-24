import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../../screens/user/base.dart';
import '../../screens/user/homepage.dart';
import '../../screens/user/historyreport.dart';
import '../../screens/user/notification.dart';
import '../../screens/user/profilepage.dart';
import '../../screens/auth/login.dart';
import '../../screens/auth/signup.dart';
import '../../screens/user/tnc.dart';
import '../../screens/auth/individual_signup.dart';
import '../../screens/auth/business_signup.dart';
import '../../screens/user/individual_editprofile.dart';
import '../../screens/user/business_editprofile.dart';
import '../../screens/user/privacypolicy.dart';
import '../../screens/user/rating.dart';
import '../../screens/user/feedback.dart';
import '../../screens/user/reportwaste.dart';
import '../../screens/user/successpage.dart';
import '../../screens/user/report_result.dart';
import '../../screens/user/wastelist.dart';
import '../../screens/user/volunteercollected.dart';

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
        '/report_result': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args != null) {
            return ReportResultPage(report: args as dynamic);
          }
          return const Scaffold(body: Center(child: Text("Error: No Report Data")));
        },
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