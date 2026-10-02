import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/timetable_model.dart';
import '../models/attendance_model.dart';
import '../services/supabase_service.dart';

class TimetableProvider extends ChangeNotifier {
  List<TimetableSlot> _timetable = [];
  List<StudentAttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;

  List<TimetableSlot> get timetable => _timetable;
  List<StudentAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchTimetableAndAttendance() async {
    _isLoading = true;
    notifyListeners();
    if (_timetable.isEmpty) {
      _timetable = _generateDefaultAidsTimetable();
    }
    _attendanceRecords = await _service.getAttendanceRecords();
    _isLoading = false;
    notifyListeners();
  }

  /// Highlight current period dynamically based on time
  Map<String, dynamic> getCurrentPeriodInfo() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final timeInMinutes = hour * 60 + minute;

    // Period times in minutes from midnight
    // I: 9:00 - 9:50 (540 - 590)
    // II: 9:50 - 10:40 (590 - 640)
    // FN Break: 10:40 - 10:55 (640 - 655)
    // III: 10:55 - 11:45 (655 - 705)
    // IV: 11:45 - 12:35 (705 - 755)
    // Lunch: 12:35 - 13:20 (755 - 800)
    // V: 1:20 - 2:05 (800 - 845)
    // VI: 2:05 - 2:50 (845 - 890)
    // AN Break: 2:50 - 3:00 (890 - 900)
    // VII: 3:00 - 3:45 (900 - 945)
    // VIII: 3:45 - 4:30 (945 - 990)

    int activePeriodNum = 1;
    String status = 'Active Class';

    if (timeInMinutes < 540) {
      activePeriodNum = 1;
      status = 'Classes Start at 9:00 AM';
    } else if (timeInMinutes >= 540 && timeInMinutes < 590) {
      activePeriodNum = 1;
    } else if (timeInMinutes >= 590 && timeInMinutes < 640) {
      activePeriodNum = 2;
    } else if (timeInMinutes >= 640 && timeInMinutes < 655) {
      activePeriodNum = 2;
      status = 'FN Tea Break (10:40–10:55 AM)';
    } else if (timeInMinutes >= 655 && timeInMinutes < 705) {
      activePeriodNum = 3;
    } else if (timeInMinutes >= 705 && timeInMinutes < 755) {
      activePeriodNum = 4;
    } else if (timeInMinutes >= 755 && timeInMinutes < 800) {
      activePeriodNum = 4;
      status = 'Lunch Break (12:35–1:20 PM)';
    } else if (timeInMinutes >= 800 && timeInMinutes < 845) {
      activePeriodNum = 5;
    } else if (timeInMinutes >= 845 && timeInMinutes < 890) {
      activePeriodNum = 6;
    } else if (timeInMinutes >= 890 && timeInMinutes < 900) {
      activePeriodNum = 6;
      status = 'AN Break (2:50–3:00 PM)';
    } else if (timeInMinutes >= 900 && timeInMinutes < 945) {
      activePeriodNum = 7;
    } else if (timeInMinutes >= 945 && timeInMinutes <= 990) {
      activePeriodNum = 8;
    } else {
      activePeriodNum = 8;
      status = 'Classes Ended for Today';
    }

    final currentSlot = _timetable.firstWhere(
      (s) => s.periodNum == activePeriodNum,
      orElse: () => _timetable.first,
    );

    final nextPeriodNum = (activePeriodNum < 8) ? activePeriodNum + 1 : 1;
    final nextSlot = _timetable.firstWhere(
      (s) => s.periodNum == nextPeriodNum,
      orElse: () => _timetable.first,
    );

    return {
      'currentPeriodNum': activePeriodNum,
      'statusMessage': status,
      'currentSlot': currentSlot,
      'nextSlot': nextSlot,
    };
  }

  Future<void> markAttendance({
    required String registerNumber,
    required String studentName,
    required String status,
    int periodNum = 1,
  }) async {
    final today = DateTime.now().toString().split(' ')[0];
    final existingIndex = _attendanceRecords.indexWhere(
      (r) => r.date == today && r.registerNumber == registerNumber && r.periodNum == periodNum,
    );

    final record = StudentAttendanceRecord(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}_$registerNumber',
      date: today,
      registerNumber: registerNumber,
      studentName: studentName,
      subjectCode: 'AI&DS-V',
      periodNum: periodNum,
      status: status,
      markedAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _attendanceRecords[existingIndex] = record;
    } else {
      _attendanceRecords.add(record);
    }

    await _service.saveAttendanceRecords(_attendanceRecords);
    notifyListeners();
  }

  List<TimetableSlot> _generateDefaultAidsTimetable() {
    return [
      TimetableSlot(id: 't1', day: 'Monday', periodNum: 1, timeSlot: '9:00–9:50 AM', subjectCode: 'DL', subjectName: 'Deep Learning', facultyName: 'Ms M. Punitha'),
      TimetableSlot(id: 't2', day: 'Monday', periodNum: 2, timeSlot: '9:50–10:40 AM', subjectCode: 'DIS', subjectName: 'Data and Information Security', facultyName: 'Mr G. Devanavan'),
      TimetableSlot(id: 't3', day: 'Monday', periodNum: 3, timeSlot: '10:55–11:45 AM', subjectCode: 'DC', subjectName: 'Distributed Computing', facultyName: 'Mr N. Sabarivasan'),
      TimetableSlot(id: 't4', day: 'Monday', periodNum: 4, timeSlot: '11:45 AM–12:35 PM', subjectCode: 'BDA', subjectName: 'Big Data Analytics', facultyName: 'Mrs P. Bharathi'),
      TimetableSlot(id: 't5', day: 'Monday', periodNum: 5, timeSlot: '1:20–2:05 PM', subjectCode: 'CC', subjectName: 'Cloud Computing', facultyName: 'Mrs N. Gomathy'),
      TimetableSlot(id: 't6', day: 'Monday', periodNum: 6, timeSlot: '2:05–2:50 PM', subjectCode: 'NS', subjectName: 'Network Security', facultyName: 'Mrs V. Kayalvizhi'),
      TimetableSlot(id: 't7', day: 'Monday', periodNum: 7, timeSlot: '3:00–3:45 PM', subjectCode: 'DRRM', subjectName: 'Disaster Risk Reduction & Mgmt', facultyName: 'Mr S. Sivaraj-ECE'),
      TimetableSlot(id: 't8', day: 'Monday', periodNum: 8, timeSlot: '3:45–4:30 PM', subjectCode: 'TNSDC', subjectName: 'AI & Green Skills Foundations', facultyName: 'Mr N. Sabarivasan & Ms Mahalakshmi'),
    ];
  }
}
