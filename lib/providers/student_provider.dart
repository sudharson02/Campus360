import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/supabase_service.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalStudentsCount => _students.length;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _students = await _service.getStudents();
    } catch (e) {
      _error = 'Failed to load students: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent(Student student) async {
    // Unique register number check
    if (_students.any((s) => s.registerNumber == student.registerNumber)) {
      _error = 'Register Number ${student.registerNumber} already exists!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    await _service.saveStudent(student);
    _students.add(student);
    _students.sort((a, b) => a.registerNumber.compareTo(b.registerNumber));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateStudent(Student student) async {
    _isLoading = true;
    notifyListeners();
    await _service.saveStudent(student);
    final index = _students.indexWhere((s) => s.registerNumber == student.registerNumber);
    if (index >= 0) {
      _students[index] = student;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteStudent(String regNo) async {
    _isLoading = true;
    notifyListeners();
    await _service.deleteStudent(regNo);
    _students.removeWhere((s) => s.registerNumber == regNo);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Student? getStudentByRegNo(String regNo) {
    try {
      return _students.firstWhere((s) => s.registerNumber == regNo);
    } catch (_) {
      return null;
    }
  }
}
