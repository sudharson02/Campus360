class TimetableSlot {
  final String id;
  final String day; // 'Monday', 'Tuesday', etc.
  final int periodNum; // 1 to 8
  final String timeSlot;
  final String subjectCode;
  final String subjectName;
  final String facultyName;
  final String room;

  TimetableSlot({
    required this.id,
    required this.day,
    required this.periodNum,
    required this.timeSlot,
    required this.subjectCode,
    required this.subjectName,
    required this.facultyName,
    this.room = 'LH-302',
  });

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      id: json['id']?.toString() ?? '',
      day: json['day'] ?? 'Monday',
      periodNum: json['period_num'] ?? json['periodNum'] ?? 1,
      timeSlot: json['time_slot'] ?? json['timeSlot'] ?? '',
      subjectCode: json['subject_code'] ?? json['subjectCode'] ?? 'DL',
      subjectName: json['subject_name'] ?? json['subjectName'] ?? 'Deep Learning',
      facultyName: json['faculty_name'] ?? json['facultyName'] ?? 'Ms M. Punitha',
      room: json['room'] ?? 'LH-302',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'period_num': periodNum,
      'time_slot': timeSlot,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'faculty_name': facultyName,
      'room': room,
    };
  }
}
