import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import 'homepage.dart';
import 'wastelist.dart';
import 'notification.dart';
import 'profilepage.dart';
import 'mappage.dart';

class MainBasePage extends StatefulWidget {
  const MainBasePage({super.key});
  @override
  State<MainBasePage> createState() => _MainBasePageState();
}

class _MainBasePageState extends State<MainBasePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const WasteListPage(),
    const NotificationPage(),
    const MapPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: NotificationService().getUnreadCountStream(AuthService().currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF387664),
            unselectedItemColor: Colors.black38,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 2) {
                NotificationService().markAllAsRead(AuthService().currentUser?.uid ?? '');
              }
            },
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
              const BottomNavigationBarItem(icon: Icon(Icons.list), label: "Report"),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: const Icon(Icons.notifications_none),
                ),
                label: "Notification",
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          );
        },
      ),
    );
  }
}