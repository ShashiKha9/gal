import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/upcoming_order_details.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UpcomingOrdersPage extends StatefulWidget {
  const UpcomingOrdersPage({super.key});

  @override
  _UpcomingOrdersPageState createState() => _UpcomingOrdersPageState();
}

class _UpcomingOrdersPageState extends State<UpcomingOrdersPage> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedOrderStatus = 'All'; // Set default status to 'All'
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now();
    toDate = DateTime.now();
  }

  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders) {
    if (fromDate == null || toDate == null) {
      return orders;
    }

    return orders.where((order) {
      try {
        final orderDate = _dateFormat.parse(order['orderDate']);
        return orderDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(toDate!.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _getDisplayedOrders(
      UpcomingOrderProvider provider) {
    List<Map<String, dynamic>> filteredOrders;

    if (selectedOrderStatus == 'Cancelled') {
      filteredOrders = provider.cancelledOrders;
    } else if (selectedOrderStatus == 'Dispatched') {
      filteredOrders = provider.dispatchedOrders;
    } else if (selectedOrderStatus == 'Pending') {
      filteredOrders = provider.pendingOrders;
    } else {
      filteredOrders = [
        ...provider.pendingOrders,
        ...provider.dispatchedOrders,
        ...provider.cancelledOrders,
      ];
    }

    return _filterOrders(filteredOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Upcoming Orders',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From Date'),
                      ElevatedButton(
                        onPressed: () => _selectFromDate(context),
                        child:
                            Text(DateFormat('dd MMMM yyyy').format(fromDate!)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To Date'),
                      ElevatedButton(
                        onPressed: () => _selectToDate(context),
                        child: Text(DateFormat('dd MMMM yyyy').format(toDate!)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedOrderStatus,
              decoration: InputDecoration(
                labelText: "Order Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'Pending',
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: 'Dispatched',
                  child: Text('Dispatched'),
                ),
                DropdownMenuItem(
                  value: 'Cancelled',
                  child: Text('Cancelled'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOrderStatus = value;
                  // Fetch orders only when order status is changed, if needed
                  // _loadOrders();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<UpcomingOrderProvider>(
                builder: (context, provider, child) {
                  final displayedOrders = _getDisplayedOrders(provider);

                  if (displayedOrders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Orders Available',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: displayedOrders.length,
                    itemBuilder: (context, index) {
                      final order = displayedOrders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpcomingOrderDetails(
                                orderId: order['orderId'],
                              ),
                            ),
                          ).then((_) {
                            // Optionally reload orders here if necessary
                            // _loadOrders();
                          });
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID: ${order['orderId']}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Order Date: ${order['orderDate'] ?? 'No Date'}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Customer Code: ${order['customerCode'] ?? 'No Code'}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Order Placed on: ${order['orderPlacedTime'] ?? 'No Time'}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Note: ${order['note'] ?? 'No Note'}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fromDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != fromDate) {
      setState(() {
        fromDate = pickedDate;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: toDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != toDate) {
      setState(() {
        toDate = pickedDate;
      });
    }
  }
}
