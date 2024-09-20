import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/edit_order.dart';
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? order;
  bool isUpcomingOrder = false;
  bool isCancelledOrder = false;
  bool isDispatchedOrder = false;

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
          // Search for the order in upcoming, cancelled, and dispatched orders
          order = provider.upcomingOrders.firstWhere(
              (order) => order['orderId'] == widget.orderId,
              orElse: () => {});

          if (order!.isEmpty) {
            order = provider.cancelledOrders.firstWhere(
                (order) => order['orderId'] == widget.orderId,
                orElse: () => {});
            isCancelledOrder = order!.isNotEmpty;
          } else {
            isUpcomingOrder = true;
          }

          if (order!.isEmpty) {
            order = provider.dispatchedOrders.firstWhere(
                (order) => order['orderId'] == widget.orderId,
                orElse: () => {});
            isDispatchedOrder = order!.isNotEmpty;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (order == null || order!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: const Color(0xFFC41E3A),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
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
        padding: const EdgeInsets.all(16.0),
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
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Item Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Rate',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Price',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                itemName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                quantity.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '₹ ${rate.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '₹ ${price.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 2),
                  const SizedBox(height: 10),
                  Text('Sub Total: ₹ ${order!['totalAmount']}'),
                  Text('Total Amount: ₹ ${order!['totalAmount']}'),
                  Text('Advance Amount: ₹ ${order!['advanceAmount']}'),
                  Text('Balance Amount: ₹ ${order!['remainingAmount']}'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Display the action buttons only for upcoming orders
            if (isUpcomingOrder)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC41E3A),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditOrder(orderId: order!['orderId']),
                        ),
                      ).then((_) {
                        // Reload orders and refresh the UI after returning from EditOrder page
                        Provider.of<UpcomingOrderProvider>(context,
                                listen: false)
                            .loadOrders()
                            .then((_) {
                          setState(() {
                            order = Provider.of<UpcomingOrderProvider>(context,
                                    listen: false)
                                .upcomingOrders
                                .firstWhere(
                                    (order) =>
                                        order['orderId'] == widget.orderId,
                                    orElse: () => {});
                          });
                        });
                      });
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC41E3A),
                    ),
                    onPressed: () {
                      Provider.of<UpcomingOrderProvider>(context, listen: false)
                          .dispatchOrder(order!['orderId']);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Dispatch',
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
          ],
        ),
      ),
    );
  }
}
