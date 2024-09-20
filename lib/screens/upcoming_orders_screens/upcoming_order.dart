import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/upcoming_order_details.dart';
import 'package:provider/provider.dart'; // Import your provider file
import 'package:intl/intl.dart'; // For formatting dates

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
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await Provider.of<UpcomingOrderProvider>(context, listen: false)
        .loadOrders();
    await Provider.of<UpcomingOrderProvider>(context, listen: false)
        .loadCancelledOrders();
    await Provider.of<UpcomingOrderProvider>(context, listen: false)
        .loadDispatchedOrders();
    await Provider.of<UpcomingOrderProvider>(context, listen: false)
        .loadPendingOrders(); // Load pending orders
    setState(() {});
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
        _loadOrders(); // Reload orders when the date is selected
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
        _loadOrders(); // Reload orders when the date is selected
      });
    }
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
      filteredOrders = provider.cancelledOrders; // Show cancelled orders
    } else if (selectedOrderStatus == 'Dispatched') {
      filteredOrders = provider.dispatchedOrders; // Show dispatched orders
    } else if (selectedOrderStatus == 'Pending') {
      filteredOrders = provider.pendingOrders; // Show pending orders
    } else {
      // Combine pending, dispatched, and cancelled orders into one list
      filteredOrders = [
        ...provider.pendingOrders,
        ...provider.dispatchedOrders,
        ...provider.cancelledOrders,
      ];
    }

    // Apply date filtering
    return _filterOrders(filteredOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Orders'),
        backgroundColor: const Color(0xFFC41E3A),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From Date'),
                        ElevatedButton(
                          onPressed: () => _selectFromDate(context),
                          child:
                              Text(DateFormat('d MMMM yyyy').format(fromDate!)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To Date'),
                        ElevatedButton(
                          onPressed: () => _selectToDate(context),
                          child:
                              Text(DateFormat('d MMMM yyyy').format(toDate!)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10.0), // Space between rows
                DropdownButtonFormField<String>(
                  value: selectedOrderStatus,
                  decoration: const InputDecoration(
                    labelText: 'Order Status',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'Dispatched', child: Text('Dispatched')),
                    DropdownMenuItem(
                        value: 'Cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedOrderStatus = value;
                      _loadOrders(); // Reload orders based on selected status
                    });
                  },
                ),
              ],
            ),
          ),
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
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Order ID: ${order['orderId']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order Date: ${order['orderDate']}'),
                            Text('Customer Code: ${order['customerCode']}'),
                            Text(
                                'Order Placed on: ${order['orderPlacedTime']}'),
                            Text('Note: ${order['note']}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpcomingOrderDetails(
                                  orderId: order['orderId']),
                            ),
                          ).then((_) {
                            _loadOrders(); // Reload data or trigger UI refresh after returning from the details page
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
