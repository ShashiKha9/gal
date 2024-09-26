import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/scaffold_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ParkedOrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _parkedOrders = [];

  List<Map<String, dynamic>> get parkedOrders => _parkedOrders;

  // Load parked orders from SharedPreferences
  Future<void> loadParkedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersString = prefs.getString('parkedOrders');

    if (ordersString != null) {
      _parkedOrders = List<Map<String, dynamic>>.from(
        json.decode(ordersString) as List,
      );
      notifyListeners();
    }
  }

// Add a new parked order
  Future<void> addOrder(Map<String, dynamic> order) async {
    // Check if an order is already parked on the selected table and group
    final existingOrder = _parkedOrders.firstWhere(
      (o) =>
          o['tableName'] == order['tableName'] &&
          o['tablegroup'] == order['tablegroup'],
      orElse: () => {}, // Return an empty map if no existing order is found
    );

    if (existingOrder.isNotEmpty) {
      // Throw an error if the table is already occupied
      scaffoldMessage(message: 'Table already taken in this group');
      throw Exception('Table already taken in this group');
    } else {
      _parkedOrders.add(order);
      notifyListeners();
      await _saveToSharedPreferences();
      scaffoldMessage(message: 'Order parked successfully');
    }
  }

  // Save parked orders to SharedPreferences
  Future<void> _saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String ordersString = json.encode(_parkedOrders);
    await prefs.setString('parkedOrders', ordersString);
  }

  // Clear all parked orders (optional, if you need it)
  Future<void> clearParkedOrders() async {
    _parkedOrders.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parkedOrders');
  }
}
