import 'package:flutter/material.dart';

class ParkedOrderProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _parkedOrders = [];

  List<Map<String, dynamic>> get parkedOrders => _parkedOrders;

  void addOrder(Map<String, dynamic> order) {
    _parkedOrders.add(order);
    notifyListeners();
  }
}
