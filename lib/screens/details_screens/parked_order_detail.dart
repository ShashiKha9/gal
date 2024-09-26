import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:galaxy_mini/screens/home_screens/parked_orders_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ParkedOrderDetail extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Map<String, double> quantities;
  final Map<String, double> rates;
  final double totalAmount;

  const ParkedOrderDetail({
    super.key,
    required this.items,
    required this.quantities,
    required this.rates,
    required this.totalAmount,
  });

  @override
  _ParkedOrderDetailState createState() => _ParkedOrderDetailState();
}

class _ParkedOrderDetailState extends State<ParkedOrderDetail> {
  late Map<String, double> quantities;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    quantities = Map.from(widget.quantities);
    totalAmount = widget.totalAmount;
  }

  void _increaseQuantity(String itemName) {
    setState(() {
      quantities[itemName] = (quantities[itemName] ?? 0) + 1;
      totalAmount += widget.rates[itemName] ?? 0.0;
    });
  }

  void _decreaseQuantity(String itemName) {
    setState(() {
      if ((quantities[itemName] ?? 1) > 1) {
        quantities[itemName] = (quantities[itemName] ?? 0) - 1;
        totalAmount -= widget.rates[itemName] ?? 0.0;
      } else {
        quantities.remove(itemName);
        totalAmount -= widget.rates[itemName] ?? 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = widget.items
        .where((item) => quantities.containsKey(item['name']))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Summary'),
        backgroundColor: const Color(0xFFC41E3A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Order',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 13.0),
            Expanded(
              child: ListView.builder(
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  final item = displayedItems[index];
                  final itemName = item['name'];
                  final itemQuantity = quantities[itemName] ?? 0;
                  final itemRate = widget.rates[itemName] ?? 0.0;
                  final itemTotal = itemRate * itemQuantity;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName ?? 'Unnamed Item',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: Colors.redAccent,
                                    onPressed: () =>
                                        _decreaseQuantity(itemName),
                                  ),
                                  Text(
                                    '$itemQuantity',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.greenAccent,
                                    onPressed: () =>
                                        _increaseQuantity(itemName),
                                  ),
                                ],
                              ),
                              Text(
                                'Rs. ${itemTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC41E3A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 2.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rs. ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC41E3A),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: const Color(0xFFC41E3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  // Handle payment action here
                },
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: const Color(0xFFC41E3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      final currentOrder = {
                        'id': const Uuid().v4(), // Generate unique ID
                        'items': widget.items
                            .where(
                                (item) => quantities.containsKey(item['name']))
                            .toList(),
                        'quantities': Map.from(quantities),
                        'totalAmount': totalAmount,
                        'tableName':
                            'YourTableName', // Ensure you set the correct table name
                      };

                      try {
                        // Try to add the order
                        await Provider.of<ParkedOrderProvider>(context,
                                listen: false)
                            .addOrder(currentOrder);

                        // Clear the quantities and reset total amount only if order is parked successfully
                        setState(() {
                          quantities.clear();
                          totalAmount = 0.0;
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order parked successfully!'),
                          ),
                        );

                        // Optionally, navigate back to the parked order screen or any other action
                        Navigator.pop(context);
                      } catch (e) {
                        // Show error message if the table is already taken
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Park',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: const Color(0xFFC41E3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      // Handle customer action here
                    },
                    child: const Text(
                      'Customer',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: const Color(0xFFC41E3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      // Handle checkout action here
                    },
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
