class LostFoundItem {
  final String id;
  final String type; // 'lost' or 'found'
  final String title;
  final String category;
  final String description;
  final String location;
  final String date;
  final String? imageUrl;
  final String studentName;
  final String registerNumber;
  final String department;
  final String? contactPhone;
  final String status; // 'Open', 'Resolved'
  final DateTime createdAt;

  LostFoundItem({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.studentName,
    required this.registerNumber,
    required this.department,
    this.contactPhone,
    this.status = 'Open',
    required this.createdAt,
  });

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    return LostFoundItem(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'lost',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      studentName: json['student_name'] ?? json['studentName'] ?? '',
      registerNumber: json['register_number'] ?? json['registerNumber'] ?? '',
      department: json['department'] ?? 'AI&DS',
      contactPhone: json['contact_phone'] ?? json['contactPhone'],
      status: json['status'] ?? 'Open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'date': date,
      'image_url': imageUrl,
      'student_name': studentName,
      'register_number': registerNumber,
      'department': department,
      'contact_phone': contactPhone,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LostFoundItem copyWith({
    String? id,
    String? type,
    String? title,
    String? category,
    String? description,
    String? location,
    String? date,
    String? imageUrl,
    String? studentName,
    String? registerNumber,
    String? department,
    String? contactPhone,
    String? status,
    DateTime? createdAt,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      studentName: studentName ?? this.studentName,
      registerNumber: registerNumber ?? this.registerNumber,
      department: department ?? this.department,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LostFoundMatchResult {
  final LostFoundItem lostItem;
  final LostFoundItem foundItem;
  final double confidenceScore; // e.g. 0.95
  final String matchReason;

  LostFoundMatchResult({
    required this.lostItem,
    required this.foundItem,
    required this.confidenceScore,
    required this.matchReason,
  });

  int get matchPercentage => (confidenceScore * 100).round();
}
