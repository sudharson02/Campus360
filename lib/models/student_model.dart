class Student {
  final String id;
  final String registerNumber;
  final String name;
  final String college;
  final String department;
  final String year;
  final String semester;
  final String password;
  final String? profileImage;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.registerNumber,
    required this.name,
    required this.college,
    required this.department,
    required this.year,
    required this.semester,
    required this.password,
    this.profileImage,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? json['register_number'] ?? '',
      registerNumber: json['register_number'] ?? json['registerNumber'] ?? '',
      name: json['name'] ?? '',
      college: json['college'] ?? 'OASYS Institute of Technology',
      department: json['department'] ?? 'B.Tech - Artificial Intelligence and Data Science',
      year: json['year'] ?? 'III Year',
      semester: json['semester'] ?? 'V Semester',
      password: json['password'] ?? 'passoasys',
      profileImage: json['profile_image'] ?? json['profileImage'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'register_number': registerNumber,
      'name': name,
      'college': college,
      'department': department,
      'year': year,
      'semester': semester,
      'password': password,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Student copyWith({
    String? id,
    String? registerNumber,
    String? name,
    String? college,
    String? department,
    String? year,
    String? semester,
    String? password,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      registerNumber: registerNumber ?? this.registerNumber,
      name: name ?? this.name,
      college: college ?? this.college,
      department: department ?? this.department,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
