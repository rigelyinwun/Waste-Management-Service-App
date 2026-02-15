import 'package:flutter/material.dart';
import 'homepage.dart';
import 'reportwaste.dart';
import 'notification.dart';
import 'profilepage.dart';

class MainBasePage extends StatefulWidget {
  const MainBasePage({super.key});
  @override
  State<MainBasePage> createState() => _MainBasePageState();
}

class _MainBasePageState extends State<MainBasePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const ReportPage(),
    const NotificationPage(),
    const Center(child: Text("Map Page")),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF387664),
        unselectedItemColor: Colors.black38,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}