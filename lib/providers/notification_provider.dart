import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _allNotifications = [];
  bool _isLoading = false;

  List<AppNotification> get allNotifications => _allNotifications;
  bool get isLoading => _isLoading;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    _allNotifications = await _service.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  /// Filter notifications strictly by recipient role & ID
  List<AppNotification> getNotificationsForUser({
    required bool isAdmin,
    String? studentRegNo,
  }) {
    if (isAdmin) {
      return _allNotifications.where((n) {
        return n.recipientType == 'admin' || n.recipientType == 'broadcast' || n.recipientId == 'admin' || n.recipientId == 'all';
      }).toList();
    } else if (studentRegNo != null && studentRegNo.isNotEmpty) {
      return _allNotifications.where((n) {
        return n.recipientType == 'broadcast' || 
              (n.recipientType == 'student' && n.recipientId == studentRegNo) ||
              (n.recipientId == studentRegNo);
      }).toList();
    }
    return [];
  }

  int getUnreadCount({required bool isAdmin, String? studentRegNo}) {
    final list = getNotificationsForUser(isAdmin: isAdmin, studentRegNo: studentRegNo);
    return list.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _allNotifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);
      await _service.saveNotifications(_allNotifications);
      notifyListeners();
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    _allNotifications.insert(0, notification);
    await _service.saveNotifications(_allNotifications);
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _allNotifications.removeWhere((n) => n.id == notificationId);
    await _service.saveNotifications(_allNotifications);
    notifyListeners();
  }
}
