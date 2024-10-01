import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';// Adjust the import based on your project structure

class NonChargeableOrdersPage extends StatefulWidget {
  @override
  _NonChargeableOrdersPageState createState() => _NonChargeableOrdersPageState();
}

class _NonChargeableOrdersPageState extends State<NonChargeableOrdersPage> {
  List<Map<String, dynamic>> nonChargeableOrders = [];

  @override
  void initState() {
    super.initState();
    _loadNonChargeableOrders();
  }

  Future<void> _loadNonChargeableOrders() async {
    CustomerCreditProvider provider = CustomerCreditProvider();
    nonChargeableOrders = await provider.loadNonChargeableOrders();
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Non-Chargeable Orders'),
      ),
      body: nonChargeableOrders.isEmpty
          ? const Center(child: Text('No non-chargeable orders found.'))
          : ListView.builder(
              itemCount: nonChargeableOrders.length,
              itemBuilder: (context, index) {
                final order = nonChargeableOrders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Bill Number: ${order['billNumber']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Note: ${order['note']}'),
                        Text("Person's Name: ${order['personName']}"),
                        Text('Total Amount: ${order['totalAmount']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
