import 'package:flutter/material.dart';
import '../models/lost_found_model.dart';
import '../services/supabase_service.dart';
import '../services/ai_matching_service.dart';

class LostFoundProvider extends ChangeNotifier {
  List<LostFoundItem> _items = [];
  bool _isLoading = false;

  List<LostFoundItem> get items => _items;
  bool get isLoading => _isLoading;

  List<LostFoundItem> get lostItems => _items.where((i) => i.type == 'lost').toList();
  List<LostFoundItem> get foundItems => _items.where((i) => i.type == 'found').toList();

  final SupabaseService _service = SupabaseService();

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await _service.getLostFoundItems();
    _isLoading = false;
    notifyListeners();
  }

  List<LostFoundMatchResult> getAIMatches() {
    return AIMatchingService.findMatches(lostItems, foundItems);
  }

  Future<bool> addItem(LostFoundItem item) async {
    _items.insert(0, item);
    await _service.saveLostFoundItems(_items);
    notifyListeners();
    return true;
  }

  Future<bool> updateItem(LostFoundItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
      await _service.saveLostFoundItems(_items);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    await _service.saveLostFoundItems(_items);
    notifyListeners();
    return true;
  }
}
