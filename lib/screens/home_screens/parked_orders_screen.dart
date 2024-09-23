import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/screens/details_screens/parked_order_detail.dart';

class ParkedOrderScreen extends StatelessWidget {
  const ParkedOrderScreen(
      {super.key, List<Map<String, dynamic>>? parkedOrders});

  @override
  Widget build(BuildContext context) {
    final parkedOrders = Provider.of<ParkedOrderProvider>(context).parkedOrders;

    return Scaffold(
      appBar: MainAppBar(
        title: "Parked Orders",
        onSearch: (p0) {},
      ),
      body: parkedOrders.isEmpty
          ? const Center(
              child: Text(
                'No parked orders',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: parkedOrders.length,
              itemBuilder: (context, index) {
                final order = parkedOrders[index];
                final rates =
                    (order['rates'] as Map?)?.cast<String, double>() ?? {};
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                        'Order ${index + 1} - Table: ${order['tableName']}'),
                    subtitle: Text('Total: Rs. ${order['totalAmount']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkedOrderDetail(
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
