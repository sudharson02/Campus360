import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../services/supabase_service.dart';

class StaffProvider extends ChangeNotifier {
  List<Staff> _staffList = [];
  bool _isLoading = false;

  List<Staff> get staffList => _staffList;
  bool get isLoading => _isLoading;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchStaff() async {
    _isLoading = true;
    notifyListeners();
    _staffList = await _service.getStaff();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStaff(Staff staff) async {
    _staffList.add(staff);
    await _service.saveStaffLocal(_staffList);
    notifyListeners();
  }

  Future<void> updateStaffStatus(String staffId, String status, String alternativeStaff) async {
    final index = _staffList.indexWhere((s) => s.id == staffId);
    if (index >= 0) {
      _staffList[index] = _staffList[index].copyWith(
        status: status,
        assignedAlternative: alternativeStaff,
      );
      await _service.saveStaffLocal(_staffList);
      notifyListeners();
    }
  }

  Future<void> deleteStaff(String staffId) async {
    _staffList.removeWhere((s) => s.id == staffId);
    await _service.saveStaffLocal(_staffList);
    notifyListeners();
  }
}
