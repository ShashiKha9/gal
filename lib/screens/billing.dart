import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:galaxy_mini/models/table_model.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/master_settings_screens/customer_masters/add_new_customer.dart';
import 'package:galaxy_mini/screens/cash_payment_dialog.dart';
import 'package:galaxy_mini/screens/home_screens/hot_items_screen.dart';
import 'package:galaxy_mini/utils/extension.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Add this import

class BillPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Map<String, double> quantities;
  final Map<String, double> rates;
  final double totalAmount;

  const BillPage({
    super.key,
    required this.items,
    required this.quantities,
    required this.rates,
    required this.totalAmount,
    required List parkedOrders,
  });

  @override
  BillPageState createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  late Map<String, double> quantities;
  late double totalAmount;
  late SyncProvider syncProvider;
  late CustomerCreditProvider custprovider;
  String? selectedCustomerName;
  String? selectedCustomerCode;
  String? selectedPaymentMode;

  @override
  void initState() {
    super.initState();
    quantities = Map.from(widget.quantities);
    totalAmount = widget.totalAmount;
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    custprovider = Provider.of<CustomerCreditProvider>(context,
        listen: false); // Initialize _syncProvider
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

  void showOrderDetailsDialog(BuildContext context, String selectedCustomerName,
      String selectedCustomerCode) {
    if (selectedCustomerName.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please select a customer',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pop(); // Close any existing dialogs
      });
      return; // Exit the function early
    }

    DateTime now = DateTime.now();
    DateTime orderDateTime = now.add(const Duration(minutes: 10));

    // Separate controllers for date and time
    final TextEditingController orderDateController = TextEditingController(
      text:
          '${orderDateTime.day} ${_monthToString(orderDateTime.month)} ${orderDateTime.year}',
    );
    final TextEditingController orderTimeController = TextEditingController(
      text:
          '${orderDateTime.hour}:${orderDateTime.minute.toString().padLeft(2, '0')}',
    );

    final TextEditingController noteController = TextEditingController();
    final TextEditingController advanceAmountController =
        TextEditingController();
    String? selectedPaymentMode;

    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: orderDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null) {
        orderDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          orderDateTime.hour,
          orderDateTime.minute,
        );
        // Update the date controller
        orderDateController.text =
            '${orderDateTime.day} ${_monthToString(orderDateTime.month)} ${orderDateTime.year}';
      }
    }

    Future<void> selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: orderDateTime.hour, minute: orderDateTime.minute),
      );
      if (pickedTime != null) {
        orderDateTime = DateTime(
          orderDateTime.year,
          orderDateTime.month,
          orderDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        // Update the time controller
        orderTimeController.text =
            '${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Order Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker Field
                GestureDetector(
                  onTap: () async {
                    await selectDate(context);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: orderDateController,
                      decoration: const InputDecoration(
                        labelText: 'Order Date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),

                // Time Picker Field
                GestureDetector(
                  onTap: () async {
                    await selectTime(context);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: orderTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Order Time',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),

                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: advanceAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Advance Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: selectedPaymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(
                        value: 'Credit Party', child: Text('Credit Party')),
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                  ],
                  onChanged: (value) {
                    selectedPaymentMode = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Get data from the dialog
                String orderDate = orderDateController.text;
                String orderTime = orderTimeController.text;
                String note = noteController.text;

                // Convert advance amount from string to double safely
                double advanceAmount =
                    double.tryParse(advanceAmountController.text) ?? 0.0;

                String paymentMode = selectedPaymentMode ?? 'None';
                DateTime orderPlacedTime = DateTime.now();

                // Ensure totalAmount is properly fetched from widget and is not null or 0
                double totalAmount = widget.totalAmount;
                if (totalAmount == 0.0) {
                  Fluttertoast.showToast(
                    msg: 'Total amount cannot be zero!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return; // Prevent further execution if totalAmount is invalid
                }

                // Check if advanceAmount is greater than totalAmount (which shouldn't happen)
                if (advanceAmount > totalAmount) {
                  Fluttertoast.showToast(
                    msg: 'Advance amount cannot exceed total amount!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return; // Prevent further execution if advanceAmount is greater than totalAmount
                }

                // Calculate remaining amount
                double remainingAmount = totalAmount - advanceAmount;

                // Add the data from the Bill Summary
                List<Map<String, dynamic>> items = widget.items;
                Map<String, double> quantities = widget.quantities;
                Map<String, double> rates = widget.rates;
                String orderId = await Provider.of<UpcomingOrderProvider>(
                        context,
                        listen: false)
                    .generateNextOrderId();

                // Prepare order data
                Map<String, dynamic> orderData = {
                  'orderId': orderId,
                  'orderDate': orderDate,
                  'orderTime': orderTime,
                  'note': note,
                  'advanceAmount': advanceAmount,
                  'paymentMode': paymentMode,
                  'totalAmount': totalAmount,
                  'remainingAmount':
                      remainingAmount, // Include remaining amount
                  'items': items,
                  'quantities': quantities,
                  'rates': rates,
                  'customerName': selectedCustomerName, // Add customer name
                  'customerCode': selectedCustomerCode, // Add customer code
                  'orderPlacedTime': orderPlacedTime
                      .toIso8601String(), // Add time when order was placed
                };

                // Use Provider to save the order data
                Provider.of<UpcomingOrderProvider>(context, listen: false)
                    .addOrder(orderData);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  String _monthToString(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  void _showPaymentDialog(
      BuildContext context, String selectedPaymentMode, double totalAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Amount to be Paid'),
          content: Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                // Use the custprovider to place the order
                custprovider.placeOrder(selectedPaymentMode, totalAmount);

                // Close the dialog after placing the order
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTableSelectionDialog(BuildContext context) async {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    // Fetch and organize tables before showing the dialog
    await syncProvider.fetchAndOrganizeTables();

    List<Widget> tableOptions = [];

    // Debugging: Print the contents of tablesByGroup
    log('Tables by group after fetch: ${syncProvider.tablesByGroup}');

    // Generate table options based on groups and tables
    for (var group in syncProvider.tablesByGroup.keys) {
      for (var table in syncProvider.tablesByGroup[group]!) {
        tableOptions.add(
          ListTile(
            title: Text(
              '${syncProvider.tablegroupList.firstWhere((g) => g.code == group).name} - ${table.name}',
            ),
            onTap: () {
              _parkOrder(context, group, table);
              Navigator.pop(context); // Close the dialog
            },
          ),
        );
      }
    }

    // If tableOptions is empty, log a message
    if (tableOptions.isEmpty) {
      log('No tables found for selected groups.');
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Table'),
          content: SingleChildScrollView(
            child: ListBody(
              children: tableOptions,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _parkOrder(BuildContext context, String group, TableMasterModel table) {
    final currentOrder = {
      'id': const Uuid().v4(),
      'items': widget.items
          .where((item) => quantities.containsKey(item['name']))
          .toList(),
      'quantities': Map.from(quantities),
      'rates': Map.from(widget.rates),
      'totalAmount': totalAmount,
      'tableName': table.name,
    };

    try {
      // Add the order to the provider
      Provider.of<ParkedOrderProvider>(context, listen: false)
          .addOrder(currentOrder);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order parked successfully')),
      );
    } catch (e) {
      // Show error message if an order is already parked on the table
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.list_alt,
              color: Colors.white,
            ), // You can replace this icon with any relevant icon
            onPressed: () => showOrderDetailsDialog(
                context, selectedCustomerName!, selectedCustomerCode!),
          ),
        ],
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCustomerName != null
                        ? 'Selected Customer: $selectedCustomerName, $selectedCustomerCode'
                        : '',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
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
            const SizedBox(height: 10.0),
            Row(
              children: [
                // Payment Mode Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                      // Handle payment mode selection
                      log('Selected Payment Mode: $selectedPaymentMode');
                    },
                    value: selectedPaymentMode ??
                        (syncProvider.paymentList.isNotEmpty
                            ? syncProvider.paymentList
                                .firstWhere(
                                  (paymentMode) => paymentMode.isDefault,
                                  orElse: () => syncProvider.paymentList
                                      .first, // Fallback to the first item
                                )
                                .type
                            : null), // Handle the case if the paymentList is empty
                  ),
                ),

                const SizedBox(width: 16.0), // Add spacing between fields
                // Discount TextField
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Discount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 10.0),
                    ),
                    keyboardType:
                        TextInputType.number, // Assuming discount is a number
                    onChanged: (value) {
                      // Handle discount change
                    },
                  ),
                ),
              ],
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
                    onPressed: () {
                      // Show table selection dialog
                      _showTableSelectionDialog(context);
                    },
                    child: const Text(
                      'Park',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Customer Data"),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: syncProvider.customerList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final customer =
                                      syncProvider.customerList[index];
                                  return ListTile(
                                    title: Text(
                                      '${customer.customerCode ?? 'No Code'} - ${customer.name ?? 'Unnamed'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold), // Optional styling
                                    ),
                                    subtitle: Text(
                                      'Mobile: ${customer.mobile1 ?? 'No Number'}',
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedCustomerName = customer.name;
                                        selectedCustomerCode = customer
                                            .customerCode; // Update selected customer name
                                      });
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text("Close"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddNewCustomer())); // Close the dialog
                                },
                                child: const Text("Add new customer"),
                              ),
                            ],
                          );
                        },
                      );
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
                      if (selectedPaymentMode == 'Cash') {
                        // Show the cash payment dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CashPaymentDialog(
                              totalAmount: totalAmount,
                              onConfirm: (receivedAmount) {
                                final creditPartyProvider =
                                    Provider.of<CustomerCreditProvider>(
                                  context,
                                  listen: false,
                                );

                                creditPartyProvider.storeCreditPartyData(
                                    selectedCustomerName!,
                                    selectedCustomerCode!,
                                    totalAmount,
                                    receivedAmount.toString(),
                                    'Cash' // Payment mode
                                    );

                                Navigator.of(context).pop(); // Close the dialog
                              },
                              customerName: '',
                              customerCode: '',
                            );
                          },
                        );
                      } else if (selectedPaymentMode == 'Credit Party') {
                        // Check if a customer is selected
                        if (selectedCustomerName != null &&
                            selectedCustomerCode != null) {
                          // Show the payment dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String?
                                  enteredAmount; // Variable to store entered amount
                              String?
                                  selectedPaymentModeInDialog; // Variable for selected payment mode in dialog

                              return AlertDialog(
                                title: const Text('Payment Confirmation'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        'Total Amount: Rs. ${totalAmount.toStringAsFixed(2)}'),
                                    const SizedBox(height: 16.0),
                                    // Text field for amount
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Enter Amount',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        enteredAmount = value;
                                      },
                                    ),
                                    const SizedBox(height: 16.0),
                                    // Dropdown for payment mode inside the dialog
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Payment Mode',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: syncProvider.paymentList
                                          .map((paymentMode) =>
                                              DropdownMenuItem<String>(
                                                value: paymentMode.type,
                                                child: Text(paymentMode.type),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        selectedPaymentModeInDialog = value;
                                      },
                                      value: selectedPaymentModeInDialog,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Retrieve the CustomerCreditProvider from the context
                                      final creditPartyProvider =
                                          Provider.of<CustomerCreditProvider>(
                                              context,
                                              listen: false);

                                      // Get current highest Bill Number and Payment ID
                                      int currentBillNumber =
                                          await creditPartyProvider
                                              .getCurrentBillNumber();
                                      int currentPaymentId =
                                          await creditPartyProvider
                                              .getCurrentPaymentId();

                                      // Increment to generate new Bill Number and Payment ID
                                      final newBillNumber =
                                          'BILL-${currentBillNumber + 1}';
                                      final newPaymentId =
                                          'PAY-${currentPaymentId + 1}';

                                      final currentDate = DateTime.now();
                                      final billDate =
                                          currentDate.toStandardDtTime();
                                      final paymentDate =
                                          currentDate.toStandardDtTime();

                                      // Call the function to store the credit party data
                                      await creditPartyProvider.storeBillData(
                                        billNumber: newBillNumber,
                                        billDate: billDate,
                                        totalAmount: totalAmount,
                                        selectedCustomerName:
                                            selectedCustomerName!,
                                        selectedCustomerCode:
                                            selectedCustomerCode!,
                                        items: widget.items, // Pass the items
                                        quantities: widget
                                            .quantities, // Pass the quantities
                                        rates: widget.rates,
                                      );

                                      await creditPartyProvider
                                          .storePaymentData(
                                        paymentId: newPaymentId,
                                        paymentDate: paymentDate,
                                        selectedCustomerName:
                                            selectedCustomerName!,
                                        selectedCustomerCode:
                                            selectedCustomerCode!,
                                        paymentMode:
                                            selectedPaymentModeInDialog ??
                                                selectedPaymentMode!,
                                        enteredAmount: enteredAmount ?? '0',
                                      );

                                      // Update the stored numbers
                                      await creditPartyProvider
                                          .setCurrentBillNumber(
                                              currentBillNumber + 1);
                                      await creditPartyProvider
                                          .setCurrentPaymentId(
                                              currentPaymentId + 1);

                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          // Show message to select a customer
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please select a customer before proceeding.'),
                            ),
                          );
                        }
                      } else {
                        // Proceed with other payment modes
                        if (selectedPaymentMode == 'UPI' ||
                            selectedPaymentMode == 'Card') {
                          _showPaymentDialog(
                              context, selectedPaymentMode!, totalAmount);
                        } else {
                          // Handle other payment modes or show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please proceed with Rs. ${totalAmount.toStringAsFixed(2)} or select another option',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
