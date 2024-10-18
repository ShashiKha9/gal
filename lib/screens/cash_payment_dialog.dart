import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/screens/setting_screens/ble_controller.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
// Import your BLE controller

class CashPaymentDialog extends StatefulWidget {
  final String customerName;
  final String customerCode;
  final double totalAmount;
  final String? selectedPaymentMode;
  final Function(double receivedAmount) onConfirm;

  const CashPaymentDialog({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
    required this.selectedPaymentMode,
    required this.customerName,
    required this.customerCode,
  });

  @override
  _CashPaymentDialogState createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  double receivedAmount = 0.0;
  double returnAmount = 0.0;
  int billNumber = 0;

  final BleController bleController =
      Get.put(BleController()); // Initialize the BLE controller

  @override
  void initState() {
    super.initState();
    _loadCurrentBillNumber();
  }

  Future<void> _loadCurrentBillNumber() async {
    final creditPartyProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);
    int currentBillNumber = await creditPartyProvider.getCurrentBillNumber();

    setState(() {
      billNumber = currentBillNumber + 1;
    });
  }

  Future<void> _updateBillNumber() async {
    final creditPartyProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);
    await creditPartyProvider.setCurrentBillNumber(billNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cash Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Amount: Rs. ${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Received Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                receivedAmount = double.tryParse(value) ?? 0.0;
                returnAmount = receivedAmount - widget.totalAmount;
              });
            },
          ),
          const SizedBox(height: 16.0),
          Text(
            'Return Amount: Rs. ${returnAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Bill Number: BILL-$billNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Store the cash payment data in SharedPreferences along with the bill number
            final creditPartyProvider =
                Provider.of<CustomerCreditProvider>(context, listen: false);

            await creditPartyProvider.storeCashPaymentData(
              widget.customerName,
              widget.customerCode,
              widget.totalAmount,
              receivedAmount,
              returnAmount,
              billNumber,
              widget.selectedPaymentMode,
            );

            // Update bill number for the next transaction
            await _updateBillNumber();

            // Print the payment details
            String printData = '''
              Customer Name: ${widget.customerName}
              Customer Code: ${widget.customerCode}
              Total Amount: Rs. ${widget.totalAmount.toStringAsFixed(2)}
              Received Amount: Rs. ${receivedAmount.toStringAsFixed(2)}
              Return Amount: Rs. ${returnAmount.toStringAsFixed(2)}
              Bill Number: BILL-$billNumber
            ''';
            bleController.printData(printData); // Call the print function

            // Close the dialog
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
