import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:provider/provider.dart';

class CashPaymentDialog extends StatefulWidget {
  final String customerName; // Add customer name
  final String customerCode; // Add customer code
  final double totalAmount;
  final Function(double receivedAmount) onConfirm;

  const CashPaymentDialog({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
    required this.customerName, // Initialize customer name
    required this.customerCode, // Initialize customer code
  });

  @override
  _CashPaymentDialogState createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  double receivedAmount = 0.0;
  double returnAmount = 0.0;

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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Store the cash payment data in SharedPreferences
            final creditPartyProvider =
                Provider.of<CustomerCreditProvider>(context, listen: false);

            // Pass the required parameters: customer name, customer code, total amount, received amount, return amount
            creditPartyProvider.storeCashPaymentData(
              widget.customerName, // Customer name
              widget.customerCode, // Customer code
              widget.totalAmount,  // Total amount
              receivedAmount,      // Received amount
              returnAmount,        // Return amount
            );

            // Close the dialog
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
