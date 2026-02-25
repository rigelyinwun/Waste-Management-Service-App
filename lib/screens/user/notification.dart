import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../models/notification_model.dart';
import 'package:intl/intl.dart';
import 'volunteercollected.dart';

class NotifStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFE8F3ED);
  static const Color textGrey = Color(0xFF757575);
  static const String font = 'LexendExa';
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: const Color(0xFF387664),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid ?? '';
    final NotificationService notificationService = NotificationService();

    return Scaffold(
      backgroundColor: NotifStyles.backgroundMint,
      appBar: _buildAppBar("Notification"),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotificationsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error loading notifications: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationCard(
                title: notif.title,
                subtitle: notif.subtitle,
                time: DateFormat('h:mm a').format(notif.time.toDate()),
                onTap: () async {
                  if (notif.type == 'collection_request' && notif.relatedId != null) {
                    final report = await ReportService().getReportById(notif.relatedId!);
                    if (report != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VolunteerCollectedPage(
                            report: report,
                            volunteerId: notif.senderId,
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.recycling, color: NotifStyles.headerTeal, size: 35),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}