import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    final isAdmin = auth.isAdmin;
    final studentRegNo = auth.currentStudent?.registerNumber;

    final userNotifs = notifProvider.getNotificationsForUser(
      isAdmin: isAdmin,
      studentRegNo: studentRegNo,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Alerts (${userNotifs.length})' : 'My Notifications (${userNotifs.length})'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(LucideIcons.send),
              tooltip: 'Send Broadcast Alert',
              onPressed: () => _showBroadcastModal(context, notifProvider),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userNotifs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bellOff, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('No notifications found', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userNotifs.length,
                  itemBuilder: (context, index) {
                    final notif = userNotifs[index];
                    final dateStr = DateFormat('MMM d, h:mm a').format(notif.createdAt);

                    return Dismissible(
                      key: Key(notif.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.trash2, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        notifProvider.deleteNotification(notif.id);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: notif.isRead ? AppColors.surface : AppColors.primaryLight.withOpacity(0.5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: notif.recipientType == 'admin' 
                                ? AppColors.accent.withOpacity(0.2) 
                                : AppColors.primary.withOpacity(0.2),
                            child: Icon(
                              notif.recipientType == 'admin' ? LucideIcons.shieldCheck : LucideIcons.bell,
                              color: notif.recipientType == 'admin' ? AppColors.accent : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Text(
                                dateStr,
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              notif.message,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                          onTap: () {
                            notifProvider.markAsRead(notif.id);
                          },
                          trailing: IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              notifProvider.deleteNotification(notif.id);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showBroadcastModal(BuildContext context, NotificationProvider provider) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Campus Announcement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Title', hint: 'e.g. Campus Holiday Announcement', controller: titleController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Message', hint: 'Enter notification message details...', controller: messageController, maxLines: 3),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Broadcast to All Students',
              icon: LucideIcons.send,
              onPressed: () {
                if (titleController.text.trim().isNotEmpty && messageController.text.trim().isNotEmpty) {
                  provider.addNotification(AppNotification(
                    id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                    recipientType: 'broadcast',
                    recipientId: 'all',
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
