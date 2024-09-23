import 'package:flutter/material.dart';

class ParkedOrderProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _parkedOrders = [];

  List<Map<String, dynamic>> get parkedOrders => _parkedOrders;

  void addOrder(Map<String, dynamic> order) {
    // Check if an order is already parked on the selected table
    final existingOrder = _parkedOrders.firstWhere(
      (o) => o['tableName'] == order['tableName'],
      orElse: () => {}, // Return an empty map if no existing order is found
    );

    if (existingOrder.isNotEmpty) {
      // Optionally: You can throw an error, or you could update the existing order if needed
      throw Exception('An order is already parked on this table.');
    } else {
      _parkedOrders.add(order);
      notifyListeners();
    }
  }
}
