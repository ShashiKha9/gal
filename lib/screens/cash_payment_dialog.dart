import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCurrentBillNumber();
  }

  // Load the current bill number from shared preferences
  Future<void> _loadCurrentBillNumber() async {
    final creditPartyProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);
    int currentBillNumber = await creditPartyProvider.getCurrentBillNumber();

    setState(() {
      billNumber =
          currentBillNumber + 1; // Use the current bill number directly
    });
  }

  // Store the updated bill number
  Future<void> _updateBillNumber() async {
    final creditPartyProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);
    await creditPartyProvider
        .setCurrentBillNumber(billNumber); // Increment for the next bill
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cash Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Total Amount: Rs. ${widget.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 16.0),
          // Text field for received amount
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
          // Display return amount
          Text(
            'Return Amount: Rs. ${returnAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          // Display current bill number
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

            // Store payment data with bill number and selected payment mode
            await creditPartyProvider.storeCashPaymentData(
              widget.customerName,
              widget.customerCode,
              widget.totalAmount,
              receivedAmount,
              returnAmount,
              billNumber, // Pass the current bill number
              widget.selectedPaymentMode, // Pass the selected payment mode
            );

            // Update bill number for the next transaction
            await _updateBillNumber();

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
