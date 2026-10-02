class Complaint {
  final String id;
  final String studentName;
  final String registerNumber;
  final String category;
  final String subject;
  final String description;
  final String status; // 'Pending', 'In Progress', 'Resolved', 'Rejected'
  final String adminResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaint({
    required this.id,
    required this.studentName,
    required this.registerNumber,
    required this.category,
    required this.subject,
    required this.description,
    this.status = 'Pending',
    this.adminResponse = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name'] ?? json['studentName'] ?? '',
      registerNumber: json['register_number'] ?? json['registerNumber'] ?? '',
      category: json['category'] ?? 'General',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      adminResponse: json['admin_response'] ?? json['adminResponse'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'register_number': registerNumber,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'admin_response': adminResponse,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Complaint copyWith({
    String? id,
    String? studentName,
    String? registerNumber,
    String? category,
    String? subject,
    String? description,
    String? status,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      registerNumber: registerNumber ?? this.registerNumber,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
