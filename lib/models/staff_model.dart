class Staff {
  final String id;
  final String name;
  final String roleTitle;
  final String department;
  final String status; // 'Present', 'Absent'
  final String assignedAlternative;
  final String? phone;
  final String? email;

  Staff({
    required this.id,
    required this.name,
    required this.roleTitle,
    this.department = 'Artificial Intelligence and Data Science',
    this.status = 'Present',
    this.assignedAlternative = 'None',
    this.phone,
    this.email,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      roleTitle: json['role_title'] ?? json['roleTitle'] ?? 'Faculty',
      department: json['department'] ?? 'Artificial Intelligence and Data Science',
      status: json['status'] ?? 'Present',
      assignedAlternative: json['assigned_alternative'] ?? json['assignedAlternative'] ?? 'None',
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role_title': roleTitle,
      'department': department,
      'status': status,
      'assigned_alternative': assignedAlternative,
      'phone': phone,
      'email': email,
    };
  }

  Staff copyWith({
    String? id,
    String? name,
    String? roleTitle,
    String? department,
    String? status,
    String? assignedAlternative,
    String? phone,
    String? email,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      roleTitle: roleTitle ?? this.roleTitle,
      department: department ?? this.department,
      status: status ?? this.status,
      assignedAlternative: assignedAlternative ?? this.assignedAlternative,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
