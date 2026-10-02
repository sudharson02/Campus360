class FoodItem {
  final String id;
  final String date;
  final String menuItems;
  final int totalMeals;
  final int servableStudents;
  final int remainingMeals;
  final String status; // 'Available', 'Completed'
  final DateTime updatedAt;

  FoodItem({
    required this.id,
    required this.date,
    required this.menuItems,
    required this.totalMeals,
    required this.servableStudents,
    required this.remainingMeals,
    required this.status,
    required this.updatedAt,
  });

  bool get isAvailable => remainingMeals > 0 && status != 'Completed';

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final remaining = json['remaining_meals'] ?? json['remainingMeals'] ?? 0;
    return FoodItem(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      menuItems: json['menu_items'] ?? json['menuItems'] ?? 'South Indian Meals',
      totalMeals: json['total_meals'] ?? json['totalMeals'] ?? 500,
      servableStudents: json['servable_students'] ?? json['servableStudents'] ?? 500,
      remainingMeals: remaining,
      status: remaining <= 0 ? 'Completed' : (json['status'] ?? 'Available'),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'menu_items': menuItems,
      'total_meals': totalMeals,
      'servable_students': servableStudents,
      'remaining_meals': remainingMeals,
      'status': isAvailable ? 'Available' : 'Completed',
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FoodItem copyWith({
    String? id,
    String? date,
    String? menuItems,
    int? totalMeals,
    int? servableStudents,
    int? remainingMeals,
    String? status,
    DateTime? updatedAt,
  }) {
    final newRemaining = remainingMeals ?? this.remainingMeals;
    return FoodItem(
      id: id ?? this.id,
      date: date ?? this.date,
      menuItems: menuItems ?? this.menuItems,
      totalMeals: totalMeals ?? this.totalMeals,
      servableStudents: servableStudents ?? this.servableStudents,
      remainingMeals: newRemaining,
      status: newRemaining <= 0 ? 'Completed' : (status ?? this.status),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
