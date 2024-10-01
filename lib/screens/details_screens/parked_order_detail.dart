import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/cash_payment_dialog.dart';
import 'package:galaxy_mini/screens/master_settings_screens/customer_masters/add_new_customer.dart';
import 'package:galaxy_mini/utils/extension.dart';
import 'package:provider/provider.dart';

class ParkedOrderDetail extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Map<String, double> quantities;
  final Map<String, double> rates;
  final double totalAmount;
  final String tableName;
  final String tableGroup;

  const ParkedOrderDetail({
    super.key,
    required this.items,
    required this.quantities,
    required this.rates,
    required this.totalAmount,
    required this.tableName,
    required this.tableGroup,
  });

  @override
  _ParkedOrderDetailState createState() => _ParkedOrderDetailState();
}

class _ParkedOrderDetailState extends State<ParkedOrderDetail> {
  late Map<String, double> quantities;
  late double totalAmount;
  late SyncProvider syncProvider;
  late ParkedOrderProvider parkprovider;
  String? selectedPaymentMode;
  String? selectedCustomerName;
  String? selectedCustomerCode;

  @override
  void initState() {
    super.initState();
    quantities = Map.from(widget.quantities);
    totalAmount = widget.totalAmount;
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    parkprovider = Provider.of<ParkedOrderProvider>(context, listen: false);
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

  void _showPaymentDialog(
      BuildContext context, String selectedPaymentMode, double totalAmount) {
    final custprovider =
        Provider.of<CustomerCreditProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Amount to be Paid'),
          content: Text('Total Amount: Rs. ${totalAmount.toStringAsFixed(2)}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                // Use the custprovider to store payment data
                if (selectedPaymentMode == 'UPI' ||
                    selectedPaymentMode == 'Card') {
                  await custprovider.storeCardUpiPayment(totalAmount);
                }

                // Close the dialog after storing the payment
                // _disposeOrder(context);
                // await parkprovider.removeParkedOrder(
                //     widget.tableName, widget.tableGroup);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // void _disposeOrder(BuildContext context) {
  //   setState(() {
  //     // Clear the items, quantities, rates, and any other relevant data.
  //     widget.items.clear(); // Clear all items
  //     quantities.clear(); // Clear all quantities
  //     widget.rates.clear(); // Clear all rates
  //     selectedPaymentMode = null; // Reset the payment mode
  //     selectedCustomerName = null; // Clear customer name
  //     selectedCustomerCode = null; // Clear customer code
  //     totalAmount = 0.0; // Reset the total amount
  //   });

  //   // Navigate back to a specific screen or until there are no more screens
  //   Navigator.popUntil(context, (route) => route.isFirst);
  // }

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
                              selectedPaymentMode: selectedPaymentMode,
                              onConfirm: (receivedAmount) {
                                // final creditPartyProvider =
                                //     Provider.of<CustomerCreditProvider>(
                                //   context,
                                //   listen: false,
                                // );

                                // creditPartyProvider.storeCreditPartyData(
                                //     selectedCustomerName!,
                                //     selectedCustomerCode!,
                                //     totalAmount,
                                //     receivedAmount.toString(),
                                //     'Cash' // Payment mode
                                //     );

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

                                      // _disposeOrder(context);
                                      // await parkprovider.removeParkedOrder(
                                      //     widget.tableName, widget.tableGroup);
                                      Navigator.of(context).pop();
                                      Navigator.pop(context);
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
