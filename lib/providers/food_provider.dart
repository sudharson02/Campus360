import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/supabase_service.dart';

class FoodProvider extends ChangeNotifier {
  FoodItem? _food;
  bool _isLoading = false;

  FoodItem? get food => _food;
  bool get isLoading => _isLoading;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchFood() async {
    _isLoading = true;
    notifyListeners();
    _food = await _service.getFoodItem();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFoodMenu({
    required String menuItems,
    required int totalMeals,
    required int servableStudents,
    required int remainingMeals,
  }) async {
    final status = remainingMeals <= 0 ? 'Completed' : 'Available';
    final updated = FoodItem(
      id: _food?.id ?? 'food_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toString().split(' ')[0],
      menuItems: menuItems,
      totalMeals: totalMeals,
      servableStudents: servableStudents,
      remainingMeals: remainingMeals,
      status: status,
      updatedAt: DateTime.now(),
    );
    _food = updated;
    await _service.saveFoodItem(updated);
    notifyListeners();
  }

  Future<void> updateRemainingMeals(int newRemaining) async {
    if (_food == null) return;
    final remaining = newRemaining.clamp(0, _food!.totalMeals);
    final status = remaining <= 0 ? 'Completed' : 'Available';
    _food = _food!.copyWith(
      remainingMeals: remaining,
      status: status,
      updatedAt: DateTime.now(),
    );
    await _service.saveFoodItem(_food!);
    notifyListeners();
  }
}
