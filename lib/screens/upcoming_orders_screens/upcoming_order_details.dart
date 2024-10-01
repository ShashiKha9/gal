import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
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
  late SyncProvider syncProvider;
  String? selectedPaymentMode;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    syncProvider.getTaxAll();
  }

  double _calculateTotalWithTax(double subTotal) {
    // Fetch tax values, ensuring to handle potential nulls or empty values
    double cgst = double.tryParse(syncProvider.taxList.first.cGst) ??
        0.0; // Replace with actual field names from your provider
    double sgst = double.tryParse(syncProvider.taxList.first.sgst) ?? 0.0;
    double igst = double.tryParse(syncProvider.taxList.first.iGst) ?? 0.0;

    // Calculate total tax
    double totalTax = (cgst + sgst + igst);

    // Return the total amount including tax
    return subTotal + subTotal * (totalTax / 100);
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

  // Function to display the dispatch alert dialog
  void _showDispatchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Balance Amount: ₹ ${order!['remainingAmount']}'),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 10.0,
                  ),
                ),
                items: syncProvider.paymentList.map((paymentMode) {
                  return DropdownMenuItem<String>(
                    value: paymentMode.type,
                    child: Text(paymentMode.type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMode = value;
                  });
                  // Log the selected payment mode
                  log('Selected Payment Mode: $selectedPaymentMode');
                },
                value: selectedPaymentMode ??
                    (syncProvider.paymentList.isNotEmpty
                        ? syncProvider.paymentList
                            .firstWhere(
                              (paymentMode) => paymentMode.isDefault,
                              orElse: () => syncProvider.paymentList.first,
                            )
                            .type
                        : null),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Add the dispatch order logic here

                // Get the customer credit provider to call savedispatchdataWithBillNumber
                final customerCreditProvider =
                    Provider.of<CustomerCreditProvider>(context, listen: false);

                // Prepare the data for saving
                double totalAmount = order![
                    'remainingAmount']; // Replace with actual total amount
                String orderDate =
                    DateTime.now().toString(); // Current order date
                String paymentUsed =
                    selectedPaymentMode ?? 'Cash'; // Payment mode
                String customerCode = order!['customerCode']; // Customer code
                String customerName = order!['customerName']; // Customer name

                // Log the data before saving
                log('Saving Dispatch Data: BillNumber (Auto Increment), TotalAmount: $totalAmount, OrderDate: $orderDate, PaymentUsed: $paymentUsed, CustomerCode: $customerCode, CustomerName: $customerName');

                // Call the savedispatchdataWithBillNumber with relevant order details
                await customerCreditProvider.savedispatchdataWithBillNumber(
                  totalAmount: totalAmount,
                  orderDate: orderDate,
                  paymentUsed: paymentUsed,
                  customerCode: customerCode,
                  customerName: customerName,
                );

                // Dispatch the order
                log('Dispatching Order ID: ${order!['orderId']}');
                Provider.of<UpcomingOrderProvider>(context, listen: false)
                    .dispatchOrder(order!['orderId']);

                Navigator.pop(context); // Close dialog after dispatch
              },
              child: const Text('Dispatch'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (order == null || order!.isEmpty) {
      return const Scaffold(
        appBar: MainAppBar(
          title: 'Order Details',
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: MainAppBar(
        title: 'Order Details',
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
                          // Sub Total
                          Text(
                            'Sub Total: ₹ ${order!['totalAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Display CGST
                          Text(
                            'CGST: ${syncProvider.taxList.first.cGst}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Display SGST
                          Text(
                            'SGST: ${syncProvider.taxList.first.sgst}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Display IGST
                          Text(
                            'IGST: ${syncProvider.taxList.first.iGst}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Updated Total Amount
                          Text(
                            'Total Amount: ₹ ${_calculateTotalWithTax(order!['totalAmount'])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                          // Advance and Remaining Amount
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
                    buttonText: "Dispatch",
                    style: const TextStyle(color: Colors.white),
                    onTap: _showDispatchDialog, // Show dispatch dialog
                  ),
                  AppButton(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
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
