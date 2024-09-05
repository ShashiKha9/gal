import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  List<String> _departments = [];

  List<Map<String, dynamic>> get items => _items;
  List<String> get departments => _departments;

  void updateItems(List<Map<String, dynamic>> newItems) {
    _items = newItems;
    notifyListeners();
  }

  void updateDepartments(List<String> newDepartments) {
    _departments = newDepartments;
    notifyListeners();
  }
}
