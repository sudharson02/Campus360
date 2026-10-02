class StudentAttendanceRecord {
  final String id;
  final String date; // YYYY-MM-DD
  final String registerNumber;
  final String studentName;
  final String subjectCode;
  final int periodNum;
  final String status; // 'Present', 'Absent'
  final DateTime markedAt;

  StudentAttendanceRecord({
    required this.id,
    required this.date,
    required this.registerNumber,
    required this.studentName,
    required this.subjectCode,
    required this.periodNum,
    required this.status,
    required this.markedAt,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceRecord(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      registerNumber: json['register_number'] ?? json['registerNumber'] ?? '',
      studentName: json['student_name'] ?? json['studentName'] ?? '',
      subjectCode: json['subject_code'] ?? json['subjectCode'] ?? 'GENERAL',
      periodNum: json['period_num'] ?? json['periodNum'] ?? 1,
      status: json['status'] ?? 'Present',
      markedAt: json['marked_at'] != null
          ? DateTime.tryParse(json['marked_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'register_number': registerNumber,
      'student_name': studentName,
      'subject_code': subjectCode,
      'period_num': periodNum,
      'status': status,
      'marked_at': markedAt.toIso8601String(),
    };
  }
}
