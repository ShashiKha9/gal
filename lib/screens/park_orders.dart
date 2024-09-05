import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/screens/order_detail.dart';

class ParkOrderScreen extends StatelessWidget {
  const ParkOrderScreen({super.key, required List<Map<String, dynamic>> parkedOrders});

  @override
  Widget build(BuildContext context) {
    final parkedOrders = Provider.of<ParkedOrderProvider>(context).parkedOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parked Orders'),
        backgroundColor: const Color(0xFFC41E3A),
      ),
      body: parkedOrders.isEmpty
          ? const Center(
              child: Text(
                'No parked orders',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: parkedOrders.length,
              itemBuilder: (context, index) {
                final order = parkedOrders[index];
                final rates =
                    (order['rates'] as Map?)?.cast<String, double>() ?? {};
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      'Order ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Total: Rs. ${order['totalAmount']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Orderdetail(
                            items:
                                List<Map<String, dynamic>>.from(order['items']),
                            quantities:
                                Map<String, double>.from(order['quantities']),
                            rates: rates,
                            totalAmount: order['totalAmount'] ?? 0.0,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
