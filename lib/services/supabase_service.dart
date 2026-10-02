import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/supabase/supabase_client.dart';
import '../models/student_model.dart';
import '../models/staff_model.dart';
import '../models/notification_model.dart';
import '../models/complaint_model.dart';
import '../models/lost_found_model.dart';
import '../models/food_model.dart';
import '../models/token_model.dart';
import '../models/timetable_model.dart';
import '../models/attendance_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? get _client => SupabaseConfig.client;

  // -------------------------------------------------------------
  // INITIALIZATION & PERSISTENCE LOAD
  // -------------------------------------------------------------
  Future<void> initStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('campus360_students')) {
      final List<Student> initialList = AppConstants.initialStudentList.map((s) {
        return Student(
          id: s['regNo']!,
          registerNumber: s['regNo']!,
          name: s['name']!,
          college: AppConstants.collegeName,
          department: AppConstants.departmentName,
          year: 'III Year',
          semester: 'V Semester',
          password: AppConstants.defaultStudentPassword,
          createdAt: DateTime.now(),
        );
      }).toList();
      await saveStudentsLocal(initialList);
    }

    if (!prefs.containsKey('campus360_staff')) {
      final initialStaff = AppConstants.subjects.map((subj) {
        return Staff(
          id: DateTime.now().millisecondsSinceEpoch.toString() + subj['code']!,
          name: subj['faculty']!,
          roleTitle: 'Assistant Professor',
          department: 'Artificial Intelligence and Data Science',
          status: 'Present',
        );
      }).toList();
      await saveStaffLocal(initialStaff);
    }
  }

  // -------------------------------------------------------------
  // STUDENTS CRUD & PERSISTENCE
  // -------------------------------------------------------------
  Future<List<Student>> getStudents() async {
    try {
      if (_client != null) {
        final response = await _client!.from('students').select().order('register_number');
        if (response is List && response.isNotEmpty) {
          final list = response.map((json) => Student.fromJson(json)).toList();
          await saveStudentsLocal(list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('Supabase fetch students error: $e');
    }
    return getStudentsLocal();
  }

  Future<List<Student>> getStudentsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_students');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => Student.fromJson(item)).toList();
    }
    return AppConstants.initialStudentList.map((s) => Student(
      id: s['regNo']!,
      registerNumber: s['regNo']!,
      name: s['name']!,
      college: AppConstants.collegeName,
      department: AppConstants.departmentName,
      year: 'III Year',
      semester: 'V Semester',
      password: AppConstants.defaultStudentPassword,
      createdAt: DateTime.now(),
    )).toList();
  }

  Future<void> saveStudentsLocal(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(students.map((s) => s.toJson()).toList());
    await prefs.setString('campus360_students', raw);
  }

  Future<bool> saveStudent(Student student) async {
    try {
      if (_client != null) {
        await _client!.from('students').upsert(student.toJson());
      }
    } catch (e) {
      debugPrint('Supabase save student error: $e');
    }
    final students = await getStudentsLocal();
    final index = students.indexWhere((s) => s.registerNumber == student.registerNumber);
    if (index >= 0) {
      students[index] = student;
    } else {
      students.add(student);
    }
    await saveStudentsLocal(students);
    return true;
  }

  Future<bool> deleteStudent(String regNo) async {
    try {
      if (_client != null) {
        await _client!.from('students').delete().eq('register_number', regNo);
      }
    } catch (e) {
      debugPrint('Supabase delete student error: $e');
    }
    final students = await getStudentsLocal();
    students.removeWhere((s) => s.registerNumber == regNo);
    await saveStudentsLocal(students);
    return true;
  }

  // -------------------------------------------------------------
  // STAFF MANAGEMENT
  // -------------------------------------------------------------
  Future<List<Staff>> getStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_staff');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => Staff.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveStaffLocal(List<Staff> staffList) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(staffList.map((s) => s.toJson()).toList());
    await prefs.setString('campus360_staff', raw);
  }

  // -------------------------------------------------------------
  // NOTIFICATIONS
  // -------------------------------------------------------------
  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_notifications');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => AppNotification.fromJson(item)).toList();
    }
    return [
      AppNotification(
        id: 'n1',
        title: 'Welcome to Campus360',
        message: 'Your official campus mobile portal is now live with real-time updates!',
        recipientType: 'broadcast',
        recipientId: 'all',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n2',
        title: 'Odd Semester Timetable Updated',
        message: 'The AI&DS 3rd Year Odd V Semester timetable is active.',
        recipientType: 'broadcast',
        recipientId: 'all',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  Future<void> saveNotifications(List<AppNotification> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((n) => n.toJson()).toList());
    await prefs.setString('campus360_notifications', raw);
  }

  // -------------------------------------------------------------
  // COMPLAINTS
  // -------------------------------------------------------------
  Future<List<Complaint>> getComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_complaints');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => Complaint.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveComplaints(List<Complaint> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((c) => c.toJson()).toList());
    await prefs.setString('campus360_complaints', raw);
  }

  // -------------------------------------------------------------
  // LOST & FOUND
  // -------------------------------------------------------------
  Future<List<LostFoundItem>> getLostFoundItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_lostfound');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => LostFoundItem.fromJson(item)).toList();
    }
    return [
      LostFoundItem(
        id: 'lf1',
        type: 'lost',
        title: 'Blue Water Bottle',
        category: 'Personal Belongings',
        description: 'Milton stainless steel blue water bottle with AI&DS sticker on top.',
        location: 'LH-302 Classroom',
        date: '2026-10-01',
        studentName: 'AKSHITHA E',
        registerNumber: '812924243001',
        department: 'B.Tech - Artificial Intelligence and Data Science',
        contactPhone: '9876543210',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LostFoundItem(
        id: 'lf2',
        type: 'found',
        title: 'Blue Milton Bottle',
        category: 'Personal Belongings',
        description: 'Found a blue steel bottle near LH-302 corridor.',
        location: 'LH-302 Corridor',
        date: '2026-10-01',
        studentName: 'ARAVINTH A',
        registerNumber: '812924243002',
        department: 'B.Tech - Artificial Intelligence and Data Science',
        contactPhone: '9876543211',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  Future<void> saveLostFoundItems(List<LostFoundItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((lf) => lf.toJson()).toList());
    await prefs.setString('campus360_lostfound', raw);
  }

  // -------------------------------------------------------------
  // FOOD
  // -------------------------------------------------------------
  Future<FoodItem> getFoodItem() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_food');
    if (raw != null) {
      return FoodItem.fromJson(jsonDecode(raw));
    }
    return FoodItem(
      id: 'f1',
      date: DateTime.now().toString().split(' ')[0],
      menuItems: 'Special South Indian Thali: Rice, Sambar, Rasam, Poriyal, Curd, Kheer & Appalam',
      totalMeals: 500,
      servableStudents: 500,
      remainingMeals: 340,
      status: 'Available',
      updatedAt: DateTime.now(),
    );
  }

  Future<void> saveFoodItem(FoodItem food) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('campus360_food', jsonEncode(food.toJson()));
  }

  // -------------------------------------------------------------
  // TOKENS
  // -------------------------------------------------------------
  Future<List<TokenTicket>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_tokens');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => TokenTicket.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveTokens(List<TokenTicket> tokens) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tokens.map((t) => t.toJson()).toList());
    await prefs.setString('campus360_tokens', raw);
  }

  // -------------------------------------------------------------
  // ATTENDANCE RECORDS
  // -------------------------------------------------------------
  Future<List<StudentAttendanceRecord>> getAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('campus360_attendance');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => StudentAttendanceRecord.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveAttendanceRecords(List<StudentAttendanceRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString('campus360_attendance', raw);
  }
}
