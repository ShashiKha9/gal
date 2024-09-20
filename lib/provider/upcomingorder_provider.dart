import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UpcomingOrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _upcomingOrders = [];
  List<Map<String, dynamic>> _cancelledOrders = [];
  List<Map<String, dynamic>> _dispatchedOrders = [];

  List<Map<String, dynamic>> get upcomingOrders => _upcomingOrders;
  List<Map<String, dynamic>> get cancelledOrders => _cancelledOrders;
  List<Map<String, dynamic>> get dispatchedOrders => _dispatchedOrders;

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
    final cancelledOrder = _upcomingOrders.firstWhere(
      (order) => order['orderId'] == orderId,
      orElse: () => {},
    );

    if (cancelledOrder.isNotEmpty) {
      _cancelledOrders.add(cancelledOrder); // Add to cancelled orders list
      _upcomingOrders.removeWhere((order) => order['orderId'] == orderId);
      notifyListeners();

      await _saveToSharedPreferences(); // Update SharedPreferences for upcoming orders
      await _saveCancelledOrders(); // Save the cancelled orders
    }
  }

  // Save cancelled orders to SharedPreferences
  Future<void> _saveCancelledOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cancelledOrdersData = jsonEncode(_cancelledOrders);
    await prefs.setString('cancelled_orders', cancelledOrdersData);

    log('Cancelled orders saved successfully to SharedPreferences.');
  }

  // Load cancelled orders from SharedPreferences
  Future<void> loadCancelledOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedCancelledData = prefs.getString('cancelled_orders');
    if (storedCancelledData != null) {
      _cancelledOrders =
          List<Map<String, dynamic>>.from(jsonDecode(storedCancelledData));
      log('Cancelled orders loaded: $_cancelledOrders');
      notifyListeners();
    }
  }

  Future<void> dispatchOrder(String orderId) async {
    final dispatchedOrder = _upcomingOrders.firstWhere(
      (order) => order['orderId'] == orderId,
      orElse: () => {},
    );

    if (dispatchedOrder.isNotEmpty) {
      _dispatchedOrders.add(dispatchedOrder); // Add to dispatched orders list
      _upcomingOrders.removeWhere((order) => order['orderId'] == orderId);
      notifyListeners();

      await _saveToSharedPreferences(); // Update SharedPreferences for upcoming orders
      await _saveDispatchedOrders(); // Save the dispatched orders
    }
  }

  // Save dispatched orders to SharedPreferences
  Future<void> _saveDispatchedOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String dispatchedOrdersData = jsonEncode(_dispatchedOrders);
    await prefs.setString('dispatched_orders', dispatchedOrdersData);

    log('Dispatched orders saved successfully to SharedPreferences.');
  }

  // Load dispatched orders from SharedPreferences
  Future<void> loadDispatchedOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedDispatchedData = prefs.getString('dispatched_orders');
    if (storedDispatchedData != null) {
      _dispatchedOrders =
          List<Map<String, dynamic>>.from(jsonDecode(storedDispatchedData));
      log('Dispatched orders loaded: $_dispatchedOrders');
      notifyListeners();
    }
  }

  Future<void> clearDispatchedOrders() async {
    _dispatchedOrders.clear();
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('dispatched_orders');
  }

  // Get pending orders (orders that are neither dispatched nor canceled)
  Future<void> loadPendingOrders() async {
    await loadOrders(); // Ensure upcoming orders are loaded
    await loadDispatchedOrders();
    await loadCancelledOrders();

    List<Map<String, dynamic>> pendingOrders = _upcomingOrders.where((order) {
      return !_dispatchedOrders.any(
              (dispatched) => dispatched['orderId'] == order['orderId']) &&
          !_cancelledOrders.any(
              (cancelled) => cancelled['orderId'] == order['orderId']);
    }).toList();

    log('Pending orders: $pendingOrders');
    notifyListeners();
  }

  List<Map<String, dynamic>> get pendingOrders {
    return _upcomingOrders.where((order) {
      return !_dispatchedOrders.any(
              (dispatched) => dispatched['orderId'] == order['orderId']) &&
          !_cancelledOrders.any(
              (cancelled) => cancelled['orderId'] == order['orderId']);
    }).toList();
  }
}
