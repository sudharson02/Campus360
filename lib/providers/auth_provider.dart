import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/student_model.dart';
import '../services/supabase_service.dart';

enum UserRole { admin, student, unauthenticated }

class AuthProvider extends ChangeNotifier {
  UserRole _role = UserRole.unauthenticated;
  Student? _currentStudent;
  String? _adminUsername;
  bool _isLoading = false;
  String? _error;

  UserRole get role => _role;
  Student? get currentStudent => _currentStudent;
  String? get adminUsername => _adminUsername;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _role == UserRole.admin;
  bool get isStudent => _role == UserRole.student;

  final SupabaseService _service = SupabaseService();

  Future<void> checkExistingSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.initStorage();
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('campus360_user_role');
      if (savedRole == 'admin') {
        _role = UserRole.admin;
        _adminUsername = prefs.getString('campus360_admin_name') ?? AppConstants.defaultAdminUsername;
      } else if (savedRole == 'student') {
        final regNo = prefs.getString('campus360_student_reg_no');
        if (regNo != null) {
          final students = await _service.getStudents();
          _currentStudent = students.firstWhere(
            (s) => s.registerNumber == regNo,
            orElse: () => Student(
              id: regNo,
              registerNumber: regNo,
              name: 'Student',
              college: AppConstants.collegeName,
              department: AppConstants.departmentName,
              year: 'III Year',
              semester: 'V Semester',
              password: AppConstants.defaultStudentPassword,
              createdAt: DateTime.now(),
            ),
          );
          _role = UserRole.student;
        }
      }
    } catch (e) {
      debugPrint('Check session error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginAdmin(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    if (username.trim() == AppConstants.defaultAdminUsername && password == AppConstants.defaultAdminPassword) {
      _role = UserRole.admin;
      _adminUsername = username.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('campus360_user_role', 'admin');
      await prefs.setString('campus360_admin_name', _adminUsername!);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Invalid Admin credentials. Default: Rajesh / nira31';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginStudent(String registerNumber, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cleanReg = registerNumber.trim();
    final students = await _service.getStudents();

    final match = students.firstWhere(
      (s) => s.registerNumber == cleanReg,
      orElse: () => Student(id: '', registerNumber: '', name: '', college: '', department: '', year: '', semester: '', password: '', createdAt: DateTime.now()),
    );

    if (match.registerNumber.isNotEmpty) {
      if (match.password == password) {
        _currentStudent = match;
        _role = UserRole.student;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('campus360_user_role', 'student');
        await prefs.setString('campus360_student_reg_no', cleanReg);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Incorrect password. Default password is: passoasys';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } else {
      _error = 'Register Number not found. Check official AI&DS student list.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeStudentPassword(String newPassword) async {
    if (_currentStudent == null) return false;
    _isLoading = true;
    notifyListeners();

    final updated = _currentStudent!.copyWith(password: newPassword);
    await _service.saveStudent(updated);
    _currentStudent = updated;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void updateCurrentStudentProfile(Student updatedStudent) {
    if (_currentStudent?.registerNumber == updatedStudent.registerNumber) {
      _currentStudent = updatedStudent;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _role = UserRole.unauthenticated;
    _currentStudent = null;
    _adminUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('campus360_user_role');
    await prefs.remove('campus360_student_reg_no');
    await prefs.remove('campus360_admin_name');
    notifyListeners();
  }
}
