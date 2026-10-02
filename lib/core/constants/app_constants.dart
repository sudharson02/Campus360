class AppConstants {
  static const String appName = 'Campus360';
  static const String collegeName = 'OASYS Institute of Technology';
  static const String collegeAddress = 'Tiruchirappalli – 621006, Tamil Nadu';
  static const String departmentName = 'B.Tech - Artificial Intelligence and Data Science';
  static const String shortDept = 'AI&DS';
  static const String currentClass = 'Third Year AI&DS – Odd V Semester (2026–2027)';

  // Admin Credentials
  static const String defaultAdminUsername = 'Rajesh';
  static const String defaultAdminPassword = 'nira31';

  // Default Student Credentials
  static const String defaultStudentPassword = 'passoasys';

  // Period Timings
  static const List<Map<String, String>> periods = [
    {'id': '1', 'name': 'Period I', 'time': '9:00 AM – 9:50 AM'},
    {'id': '2', 'name': 'Period II', 'time': '9:50 AM – 10:40 AM'},
    {'id': 'break1', 'name': 'FN Break', 'time': '10:40 AM – 10:55 AM'},
    {'id': '3', 'name': 'Period III', 'time': '10:55 AM – 11:45 AM'},
    {'id': '4', 'name': 'Period IV', 'time': '11:45 AM – 12:35 PM'},
    {'id': 'lunch', 'name': 'Lunch Break', 'time': '12:35 PM – 1:20 PM'},
    {'id': '5', 'name': 'Period V', 'time': '1:20 PM – 2:05 PM'},
    {'id': '6', 'name': 'Period VI', 'time': '2:05 PM – 2:50 PM'},
    {'id': 'break2', 'name': 'AN Break', 'time': '2:50 PM – 3:00 PM'},
    {'id': '7', 'name': 'Period VII', 'time': '3:00 PM – 3:45 PM'},
    {'id': '8', 'name': 'Period VIII', 'time': '3:45 PM – 4:30 PM'},
  ];

  // Subjects & Faculty
  static const List<Map<String, String>> subjects = [
    {'code': 'DL', 'name': 'Deep Learning', 'faculty': 'Ms M. Punitha'},
    {'code': 'DIS', 'name': 'Data and Information Security', 'faculty': 'Mr G. Devanavan'},
    {'code': 'DC', 'name': 'Distributed Computing', 'faculty': 'Mr N. Sabarivasan'},
    {'code': 'BDA', 'name': 'Big Data Analytics', 'faculty': 'Mrs P. Bharathi'},
    {'code': 'CC', 'name': 'Cloud Computing', 'faculty': 'Mrs N. Gomathy'},
    {'code': 'NS', 'name': 'Network Security', 'faculty': 'Mrs V. Kayalvizhi'},
    {'code': 'DRRM', 'name': 'Disaster Risk Reduction & Mgmt', 'faculty': 'Mr S. Sivaraj-ECE'},
    {'code': 'DLL', 'name': 'Deep Learning Laboratory', 'faculty': 'Mr N. Sabarivasan'},
    {'code': 'Lib', 'name': 'Library', 'faculty': 'AI&DS Department Staff'},
    {'code': 'TNSDC', 'name': 'AI & Green Skills Foundations', 'faculty': 'Mr N. Sabarivasan & Ms Mahalakshmi'},
  ];

  // 51 Registered Students List
  static const List<Map<String, String>> initialStudentList = [
    {'regNo': '812924243001', 'name': 'AKSHITHA E'},
    {'regNo': '812924243002', 'name': 'ARAVINTH A'},
    {'regNo': '812924243003', 'name': 'ARJUNAN M'},
    {'regNo': '812924243004', 'name': 'ARYA R'},
    {'regNo': '812924243005', 'name': 'ASWIN KUMAR M'},
    {'regNo': '812924243006', 'name': 'AYYAPPAN V'},
    {'regNo': '812924243007', 'name': 'DEVANATHAN D'},
    {'regNo': '812924243008', 'name': 'DHARUN V'},
    {'regNo': '812924243009', 'name': 'DHAYANITHI K'},
    {'regNo': '812924243010', 'name': 'DHINESHKUMAR T'},
    {'regNo': '812924243011', 'name': 'DIVYAVENI N'},
    {'regNo': '812924243012', 'name': 'GOBIKA S'},
    {'regNo': '812924243013', 'name': 'GOPALAKRISHNAN T'},
    {'regNo': '812924243014', 'name': 'HARIKARAN D'},
    {'regNo': '812924243015', 'name': 'HARIKRISHNAN C'},
    {'regNo': '812924243016', 'name': 'HARINI G'},
    {'regNo': '812924243017', 'name': 'HEMAMALINI S'},
    {'regNo': '812924243018', 'name': 'JAFFER SHATHICK N'},
    {'regNo': '812924243019', 'name': 'JAISURYA M'},
    {'regNo': '812924243020', 'name': 'JANISHA S'},
    {'regNo': '812924243021', 'name': 'KUMARESAN V'},
    {'regNo': '812924243022', 'name': 'LENIN K'},
    {'regNo': '812924243023', 'name': 'MAHENDRAN M'},
    {'regNo': '812924243024', 'name': 'MOHAMED FAJIR M'},
    {'regNo': '812924243025', 'name': 'MUGESH V'},
    {'regNo': '812924243026', 'name': 'NAVEEN R'},
    {'regNo': '812924243027', 'name': 'NITHEESH N'},
    {'regNo': '812924243028', 'name': 'PAVITHRA P'},
    {'regNo': '812924243029', 'name': 'PERIYADURAI E'},
    {'regNo': '812924243030', 'name': 'PERIYAR SELVAN A'},
    {'regNo': '812924243031', 'name': 'RAHUL W'},
    {'regNo': '812924243032', 'name': 'RAHINI S'},
    {'regNo': '812924243033', 'name': 'RAJESH B'},
    {'regNo': '812924243034', 'name': 'STUDENT 34'},
    {'regNo': '812924243035', 'name': 'RANJITH M'},
    {'regNo': '812924243036', 'name': 'SABITHRA J'},
    {'regNo': '812924243037', 'name': 'SAGANA S'},
    {'regNo': '812924243038', 'name': 'SANMUGESHWAR S'},
    {'regNo': '812924243039', 'name': 'SANTHOSH RAJU K'},
    {'regNo': '812924243040', 'name': 'SARVESHWARAN M'},
    {'regNo': '812924243041', 'name': 'SEENIVASAN R'},
    {'regNo': '812924243042', 'name': 'SRIDHAR P'},
    {'regNo': '812924243043', 'name': 'SUDHARSON A'},
    {'regNo': '812924243044', 'name': 'SURESH S'},
    {'regNo': '812924243045', 'name': 'SWETHA S'},
    {'regNo': '812924243046', 'name': 'VAIGUNTH R'},
    {'regNo': '812924243047', 'name': 'VIDYA BALAN M'},
    {'regNo': '812924243048', 'name': 'VIGNESH R'},
    {'regNo': '812924243049', 'name': 'VIMAL S'},
    {'regNo': '812924243050', 'name': 'VINNARASI V'},
    {'regNo': '812924243051', 'name': 'KEERTHIKA M'},
  ];
}
