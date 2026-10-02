class TokenTicket {
  final String id;
  final String queueType; // 'OFF', 'CAN', 'LIB'
  final int tokenNumber;
  final String studentName;
  final String registerNumber;
  final String status; // 'Waiting', 'Serving', 'Completed', 'Skipped'
  final DateTime appliedAt;
  final DateTime? calledAt;

  TokenTicket({
    required this.id,
    required this.queueType,
    required this.tokenNumber,
    required this.studentName,
    required this.registerNumber,
    this.status = 'Waiting',
    required this.appliedAt,
    this.calledAt,
  });

  factory TokenTicket.fromJson(Map<String, dynamic> json) {
    return TokenTicket(
      id: json['id']?.toString() ?? '',
      queueType: json['queue_type'] ?? json['queueType'] ?? 'OFF',
      tokenNumber: json['token_number'] ?? json['tokenNumber'] ?? 101,
      studentName: json['student_name'] ?? json['studentName'] ?? '',
      registerNumber: json['register_number'] ?? json['registerNumber'] ?? '',
      status: json['status'] ?? 'Waiting',
      appliedAt: json['applied_at'] != null
          ? DateTime.tryParse(json['applied_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      calledAt: json['called_at'] != null
          ? DateTime.tryParse(json['called_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_type': queueType,
      'token_number': tokenNumber,
      'student_name': studentName,
      'register_number': registerNumber,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'called_at': calledAt?.toIso8601String(),
    };
  }

  TokenTicket copyWith({
    String? id,
    String? queueType,
    int? tokenNumber,
    String? studentName,
    String? registerNumber,
    String? status,
    DateTime? appliedAt,
    DateTime? calledAt,
  }) {
    return TokenTicket(
      id: id ?? this.id,
      queueType: queueType ?? this.queueType,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      studentName: studentName ?? this.studentName,
      registerNumber: registerNumber ?? this.registerNumber,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      calledAt: calledAt ?? this.calledAt,
    );
  }
}
