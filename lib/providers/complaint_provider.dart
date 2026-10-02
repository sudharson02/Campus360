import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import 'notification_provider.dart';

class ComplaintProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchComplaints() async {
    _isLoading = true;
    notifyListeners();
    _complaints = await _service.getComplaints();
    _isLoading = false;
    notifyListeners();
  }

  List<Complaint> getComplaintsForStudent(String regNo) {
    return _complaints.where((c) => c.registerNumber == regNo).toList();
  }

  Future<bool> submitComplaint({
    required String studentName,
    required String registerNumber,
    required String category,
    required String subject,
    required String description,
    required NotificationProvider notificationProvider,
  }) async {
    final complaint = Complaint(
      id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      studentName: studentName,
      registerNumber: registerNumber,
      category: category,
      subject: subject,
      description: description,
      status: 'Pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _complaints.insert(0, complaint);
    await _service.saveComplaints(_complaints);

    // Rule: Send notification ONLY to Admin (not back to student submitter)
    await notificationProvider.addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Student Complaint Received',
      message: 'Complaint from $studentName ($registerNumber): "$subject"',
      recipientType: 'admin',
      recipientId: 'admin',
      createdAt: DateTime.now(),
    ));

    notifyListeners();
    return true;
  }

  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String status,
    required String adminResponse,
    required NotificationProvider notificationProvider,
  }) async {
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index >= 0) {
      final existing = _complaints[index];
      final updated = existing.copyWith(
        status: status,
        adminResponse: adminResponse,
        updatedAt: DateTime.now(),
      );
      _complaints[index] = updated;
      await _service.saveComplaints(_complaints);

      // Rule: Send notification ONLY to student creator using Register Number
      await notificationProvider.addNotification(AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Complaint Update: ${updated.subject}',
        message: 'Admin Response ($status): ${adminResponse.isEmpty ? 'Your complaint status has been updated to $status.' : adminResponse}',
        recipientType: 'student',
        recipientId: updated.registerNumber,
        createdAt: DateTime.now(),
      ));

      notifyListeners();
      return true;
    }
    return false;
  }
}
