import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/add_new_upcoming_item.dart';
import 'package:provider/provider.dart';

class EditUpcomingOrder extends StatefulWidget {
  final String orderId;

  const EditUpcomingOrder({
    super.key,
    required this.orderId,
  });

  @override
  EditUpcomingOrderState createState() => EditUpcomingOrderState();
}

class EditUpcomingOrderState extends State<EditUpcomingOrder> {
  Map<String, dynamic>? order;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  void _loadOrderData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<UpcomingOrderProvider>(context, listen: false);
      provider.loadOrders().then((_) {
        setState(() {
          order = provider.upcomingOrders.firstWhere(
              (order) => order['orderId'] == widget.orderId,
              orElse: () => {});
        });
      });
    });
  }

  void _increaseQuantity(String itemName) {
    setState(() {
      order!['quantities'][itemName] += 1;
      _updateTotals(itemName);
    });
  }

  void _decreaseQuantity(String itemName) {
    setState(() {
      if (order!['quantities'][itemName] > 1) {
        // Decrease quantity if more than 1
        order!['quantities'][itemName] -= 1;
      } else {
        // Remove the item if the quantity is 1 or less
        order!['items'].removeWhere((item) => item['name'] == itemName);
        order!['quantities'].remove(itemName);
        order!['rates'].remove(itemName);
      }
      _updateTotals(itemName); // Update totals after removing or decreasing
    });
  }

  void _updateTotals(String itemName) {
    // Update the total amount for the order
    double totalAmount = 0.0;
    for (var item in order!['items']) {
      String currentItemName = item['name'];
      totalAmount += order!['quantities'][currentItemName] *
          order!['rates'][currentItemName];
    }

    setState(() {
      order!['totalAmount'] = totalAmount;
      order!['remainingAmount'] =
          order!['totalAmount'] - order!['advanceAmount'];
    });
  }

  void _saveChanges() async {
    final provider = Provider.of<UpcomingOrderProvider>(context, listen: false);
    await provider.updateOrderInSharedPreferences(widget.orderId);
    // Navigate back or provide feedback after saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (order == null || order!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Order'),
          backgroundColor: const Color(0xFFC41E3A),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
        backgroundColor: const Color(0xFFC41E3A),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.print, color: Colors.black),
            ),
            onPressed: () {
              // Handle print action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding slightly
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text('Customer Code: ${order!['customerCode']}'),
                  Text('Customer Name: ${order!['customerName']}'),
                  Text('Order ID: ${order!['orderId']}'),
                  Text(
                      'Order Date: ${order!['orderDate']} at ${order!['orderTime']}'),
                  Text('Order Placed on: ${order!['orderPlacedTime']}'),
                  Text('Note: ${order!['note']}'),
                  const SizedBox(height: 10),
                  const Divider(thickness: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.0), // Reduced vertical padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Item Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order!['items'].length,
                    itemBuilder: (context, itemIndex) {
                      String itemName = order!['items'][itemIndex]['name'];
                      double quantity = order!['quantities'][itemName];
                      double rate = order!['rates'][itemName];
                      double price = quantity * rate;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    itemName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _decreaseQuantity(itemName),
                                        icon: const Icon(Icons.remove_circle),
                                        color: Colors.red,
                                        iconSize: 24,
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: Center(
                                          child: Text(
                                            quantity.toString(),
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _increaseQuantity(itemName),
                                        icon: const Icon(Icons.add_circle),
                                        color: Colors.green,
                                        iconSize: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Price: ₹ ${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(thickness: 2),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC41E3A),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddNewUpcomingItem(orderId: order!['orderId']),
                        ),
                      );
                    },
                    child: const Text(
                      'Add more items',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Sub Total: ₹ ${order!['totalAmount']}'),
                  Text('Total Amount: ₹ ${order!['totalAmount']}'),
                  Text('Advance Amount: ₹ ${order!['advanceAmount']}'),
                  Text('Balance Amount: ₹ ${order!['remainingAmount']}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC41E3A),
                    ),
                    onPressed: _saveChanges, // Save Changes Button
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC41E3A),
                    ),
                    onPressed: () {
                      Provider.of<UpcomingOrderProvider>(context, listen: false)
                          .cancelOrder(order!['orderId']);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
