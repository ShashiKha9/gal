import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/order_details.dart';
import 'package:provider/provider.dart'; // Import your provider file
import 'package:intl/intl.dart'; // For formatting dates

class UpcomingOrdersPage extends StatefulWidget {
  const UpcomingOrdersPage({super.key});

  @override
  _UpcomingOrdersPageState createState() => _UpcomingOrdersPageState();
}

class _UpcomingOrdersPageState extends State<UpcomingOrdersPage> {
  // Date variables for filters
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    // Set initial dates to today's date
    fromDate = DateTime.now();
    toDate = DateTime.now();
  }

  // Method to show date picker for "From Date"
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

  // Method to show date picker for "To Date"
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

  @override
  Widget build(BuildContext context) {
    // Call loadOrders() to retrieve saved upcoming orders
    Provider.of<UpcomingOrderProvider>(context, listen: false).loadOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Orders'),
        backgroundColor: const Color(0xFFC41E3A),
      ),
      body: Column(
        children: [
          // Row for From Date and To Date pickers
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // From Date picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From Date',
                    ),
                    ElevatedButton(
                      onPressed: () => _selectFromDate(context),
                      child: Text(DateFormat('dd/MM/yyyy').format(fromDate!)),
                    ),
                  ],
                ),
                // To Date picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To Date'),
                    ElevatedButton(
                      onPressed: () => _selectToDate(context),
                      child: Text(DateFormat('dd/MM/yyyy').format(toDate!)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded ListView for upcoming orders
          Expanded(
            child: Consumer<UpcomingOrderProvider>(
              builder: (context, provider, child) {
                final upcomingOrders = provider.upcomingOrders;

                if (upcomingOrders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Upcoming Orders',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: upcomingOrders.length,
                  itemBuilder: (context, index) {
                    final order = upcomingOrders[index];
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
                          // Navigate to Order Details page with only the orderId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                  orderId:
                                      order['orderId']), // Pass only orderId
                            ),
                          ).then((_) {
                            // Reload data or trigger UI refresh after returning from the details page
                            Provider.of<UpcomingOrderProvider>(context,
                                    listen: false)
                                .loadOrders();
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
