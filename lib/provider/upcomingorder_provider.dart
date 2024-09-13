import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UpcomingOrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _upcomingOrders = [];

  List<Map<String, dynamic>> get upcomingOrders => _upcomingOrders;

  // Add order to the list and save to SharedPreferences
  Future<void> addOrder(Map<String, dynamic> orderData) async {
    _upcomingOrders.add(orderData);
    notifyListeners();
    await _saveToSharedPreferences();
  }

  // Save the list of upcoming orders to SharedPreferences
  Future<void> _saveToSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_upcomingOrders);
    await prefs.setString('upcoming_orders', encodedData);

    log('Upcoming orders saved successfully to SharedPreferences.');

    await loadOrders();

    log('Reloaded the order');
  }


  // Load orders from SharedPreferences
  Future<void> loadOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('upcoming_orders');
    if (storedData != null) {
      _upcomingOrders = List<Map<String, dynamic>>.from(jsonDecode(storedData));
      log('Loaded orders: $_upcomingOrders'); // Log the loaded orders to verify the content
      notifyListeners();
    }
  }

  Future<void> storeItemDetails(
      String itemName, double qty, double totalAmount, String orderId) async {
    // Find the correct order by orderId
    final int orderIndex =
        _upcomingOrders.indexWhere((order) => order['orderId'] == orderId);

    if (orderIndex != -1) {
      Map<String, dynamic> currentOrder = _upcomingOrders[orderIndex];

      if (currentOrder['items'] == null) currentOrder['items'] = [];
      if (currentOrder['quantities'] == null) currentOrder['quantities'] = {};
      if (currentOrder['rates'] == null) currentOrder['rates'] = {};

      bool itemExists =
          currentOrder['items'].any((item) => item['name'] == itemName);

      if (!itemExists) {
        currentOrder['items'].add({'name': itemName});
      }

      currentOrder['quantities'][itemName] = qty;
      currentOrder['rates'][itemName] = totalAmount / qty;

      currentOrder['totalAmount'] =
          (currentOrder['totalAmount'] ?? 0.0) + totalAmount;
      currentOrder['remainingAmount'] = (currentOrder['totalAmount'] ?? 0.0) -
          (currentOrder['advanceAmount'] ?? 0.0);

      _upcomingOrders[orderIndex] = currentOrder;

      log('Item $itemName with quantity $qty and total amount $totalAmount saved successfully to SharedPreferences.');

      await updateOrderInSharedPreferences(
          orderId); // Update specific order in SharedPreferences
    } else {
      log('Order not found!');
    }
  }

  Future<void> updateOrderInSharedPreferences(String orderId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Find the order by orderId
    final int orderIndex =
        _upcomingOrders.indexWhere((order) => order['orderId'] == orderId);

    if (orderIndex != -1) {
      final String encodedData = jsonEncode(_upcomingOrders);
      await prefs.setString('upcoming_orders', encodedData);

      log('Order with ID $orderId updated successfully in SharedPreferences.');

      await loadOrders(); // Reload the orders after updating
      log('Orders reloaded after update.');
    } else {
      log('Order with ID $orderId not found!');
    }
  }

  // Generate the next order ID
  Future<String> generateNextOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    int nextId = (prefs.getInt('lastOrderId') ?? 0) + 1;
    await prefs.setInt('lastOrderId', nextId);
    return 'FO$nextId';
  }

  // Clear all upcoming orders (if needed)
  Future<void> clearOrders() async {
    _upcomingOrders.clear();
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('upcoming_orders');
  }

  // Cancel an order by ID and remove from SharedPreferences
  Future<void> cancelOrder(String orderId) async {
    _upcomingOrders.removeWhere((order) => order['orderId'] == orderId);
    notifyListeners();
    await _saveToSharedPreferences(); // Update SharedPreferences after deletion
  }
}
