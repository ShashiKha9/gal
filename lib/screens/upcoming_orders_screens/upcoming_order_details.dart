import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/edit_upcoming_order.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class UpcomingOrderDetails extends StatefulWidget {
  final String orderId;

  const UpcomingOrderDetails({
    super.key,
    required this.orderId,
  });

  @override
  _UpcomingOrderDetailsState createState() => _UpcomingOrderDetailsState();
}

class _UpcomingOrderDetailsState extends State<UpcomingOrderDetails> {
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
      return const Scaffold(
        appBar: MainAppBar(
          title: 'Order Details',
          isMenu: false,
        ),
        body:  Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: MainAppBar(
        title: 'Order Details',
        isMenu: false,
        actions: true,
        actionWidget: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.print),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Code: ${order!['customerCode']}'),
                          Text('Customer Name: ${order!['customerName']}'),
                          Text(
                            'Order ID: ${order!['orderId']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Order Date: ${order!['orderDate']} ${order!['orderTime']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Order Placed on: ${order!['orderPlacedTime']}'),
                          Text('Note: ${order!['note']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 2),
                  const Row(
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
                                  fontWeight: FontWeight.bold,
                                ),
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
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub Total: ₹ ${order!['totalAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Amount: ₹ ${order!['totalAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                          Text(
                            'Advance Amount: ₹ ${order!['advanceAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Balance Amount: ₹ ${order!['remainingAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Display the action buttons only for upcoming orders
            if (isUpcomingOrder)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(0),
                    style: const TextStyle(color: Colors.white),
                    buttonText: "Edit",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUpcomingOrder(
                            orderId: order!['orderId'],
                          ),
                        ),
                      ).then(
                        (_) {
                          Provider.of<UpcomingOrderProvider>(context,
                                  listen: false)
                              .loadOrders()
                              .then(
                            (_) {
                              setState(() {
                                order = Provider.of<UpcomingOrderProvider>(
                                  context,
                                  listen: false,
                                ).upcomingOrders.firstWhere(
                                      (order) =>
                                          order['orderId'] == widget.orderId,
                                      orElse: () => {},
                                    );
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  AppButton(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(0),
                    buttonText: "Dispatch",
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      Provider.of<UpcomingOrderProvider>(context, listen: false)
                          .dispatchOrder(order!['orderId']);
                      Navigator.pop(context);
                    },
                  ),
                  AppButton(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(0),
                    buttonText: "Cancel Order",
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      Provider.of<UpcomingOrderProvider>(context, listen: false)
                          .cancelOrder(order!['orderId']);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
