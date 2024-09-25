import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/customer_credit_screens/bill_detail.dart';
import 'package:galaxy_mini/screens/customer_credit_screens/custom_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerCreditDetail extends StatefulWidget {
  final String customerName;
  final String customerCode;

  const CustomerCreditDetail({
    super.key,
    required this.customerName,
    required this.customerCode,
  });

  @override
  State<CustomerCreditDetail> createState() => _CustomerCreditDetailState();
}

class _CustomerCreditDetailState extends State<CustomerCreditDetail> {
  List<Map<String, dynamic>> billData = [];
  List<Map<String, dynamic>> paymentData = [];
  String currentBillNumber = '';
  String currentPaymentId = '';
  double currentBalance = 0.0;
  late SyncProvider syncProvider;
  late CustomerCreditProvider creditProvider;
  final currentDate = DateTime.now();

  // State variable for the selected chip
  String selectedChip = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    creditProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);
  }

  Future<void> _loadData() async {
    final creditProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);

    // Load all bills and payments for this specific customer
    billData = await creditProvider.loadBillData(widget.customerCode);
    paymentData = await creditProvider.loadPaymentData(widget.customerCode);

    // Set the latest bill number and payment ID
    if (billData.isNotEmpty) {
      currentBillNumber = billData.last['billNumber'].toString();
    }
    if (paymentData.isNotEmpty) {
      currentPaymentId = paymentData.last['paymentId'].toString();
    }

    // Calculate the current balance
    currentBalance = _calculateCurrentBalance();

    setState(() {}); // Update the UI after data is loaded
  }

  double _calculateTotalBillAmount() {
    return billData.fold(
        0.0, (sum, bill) => sum + (bill['totalAmount'] ?? 0.0));
  }

  double _calculateTotalPaymentAmount() {
    return paymentData.fold(
        0.0, (sum, payment) => sum + (payment['enteredAmount'] ?? 0.0));
  }

  double _calculateCurrentBalance() {
    return _calculateTotalBillAmount() - _calculateTotalPaymentAmount();
  }

  // Function to show "Make Payment" dialog
  void _showMakePaymentDialog(
      BuildContext context,
      SyncProvider syncProvider,
      CustomerCreditProvider creditProvider,
      String selectedCustomerCode,
      String selectedCustomerName) async {
    final TextEditingController amountController = TextEditingController();
    String? selectedPaymentModeInDialog = syncProvider.paymentList.isNotEmpty
        ? syncProvider.paymentList.first.type
        : null; // Default to first available payment mode or null if list is empty

    // Fetch the current payment ID from CustomerCreditProvider
    int currentPaymentId = await creditProvider.getCurrentPaymentId();
    int newPaymentId = currentPaymentId + 1; // Increment the payment ID

    // Get the current date in your desired format
    String paymentDate =
        DateFormat('yyyy-MM-dd').format(DateTime.now()); // Example format

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Make Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter payment amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(),
                    ),
                    items: syncProvider.paymentList
                        .map((paymentMode) => DropdownMenuItem<String>(
                              value: paymentMode.type,
                              child: Text(paymentMode.type),
                            ))
                        .toList(),
                    value: selectedPaymentModeInDialog,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentModeInDialog = newValue;
                      });
                    },
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
                ElevatedButton(
                  onPressed: () async {
                    if (amountController.text.isNotEmpty &&
                        selectedPaymentModeInDialog != null) {
                      // Handle saving the payment here
                      log('Amount: ${amountController.text}, Payment Mode: $selectedPaymentModeInDialog, Payment ID: $newPaymentId, Payment Date: $paymentDate');

                      // Store the payment data using the storePaymentData function
                      await creditProvider.storePaymentData(
                        paymentId: 'PAY-$newPaymentId',
                        paymentDate: paymentDate,
                        selectedCustomerName: selectedCustomerName,
                        selectedCustomerCode: selectedCustomerCode,
                        paymentMode: selectedPaymentModeInDialog!,
                        enteredAmount: amountController.text,
                      );

                      // Update the current payment ID in SharedPreferences
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setInt('currentPaymentId', newPaymentId);

                      await _loadData();

                      // After handling the payment, close the dialog
                      Navigator.of(context).pop();
                    } else {
                      // Optionally, handle the case where the form is not filled properly
                      log('Please enter amount and select a payment mode');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Credit Details'),
      ),
      body: billData.isEmpty && paymentData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildCustomerInfo(),
                  const SizedBox(height: 16),
                  _buildChoiceChips(), // Add choice chips here
                  const SizedBox(height: 16),
                  if (selectedChip == 'All') _buildAllDataList(),
                  if (selectedChip == 'Bills') _buildBillList(),
                  if (selectedChip == 'Payments') _buildPaymentList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMakePaymentDialog(
            context, syncProvider, creditProvider,
            widget.customerCode, // Pass the customer code
            widget.customerName,
          );
        },
        child: const Icon(Icons.payment),
      ),
    );
  }

// Widget to display customer code, name, bill number, payment ID, and current balance
  Widget _buildCustomerInfo() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding around the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Customer Name:', widget.customerName),
            _buildDataRow('Customer Code:', widget.customerCode),
            _buildDataRow('Latest Bill Number:',
                currentBillNumber.isNotEmpty ? currentBillNumber : 'N/A'),
            _buildDataRow('Latest Payment ID:',
                currentPaymentId.isNotEmpty ? currentPaymentId : 'N/A'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Balance:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Rs. ${currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // New widget to build choice chips for filtering
  Widget _buildChoiceChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selectedChip == 'All',
          onSelected: (selected) {
            setState(() {
              selectedChip = 'All';
            });
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Bills'),
          selected: selectedChip == 'Bills',
          onSelected: (selected) {
            setState(() {
              selectedChip = 'Bills';
            });
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Payments'),
          selected: selectedChip == 'Payments',
          onSelected: (selected) {
            setState(() {
              selectedChip = 'Payments';
            });
          },
        ),
      ],
    );
  }

  Widget _buildAllDataList() {
    return Column(
      children: [
        _buildBillList(),
        _buildPaymentList(),
      ],
    );
  }

  Widget _buildBillList() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          billData.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: billData.length,
                  itemBuilder: (context, index) {
                    final bill = billData[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the Bill Detail Page with complete bill data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillDetailPage(billData: {
                              'billNumber': bill['billNumber'],
                              'billDate': bill['billDate'],
                              'customerName': bill['customerName'],
                              'customerCode': bill['customerCode'],
                              'totalAmount': (bill['totalAmount'] ?? 0.0)
                                  .toInt(), // Cast to int
                              'items': bill['items'],
                              'quantities': bill['quantities'],
                              'rates': bill['rates'],
                            }),
                          ),
                        );
                      },
                      child: _buildInfoBox('Bill', bill),
                    );
                  },
                )
              : const Text('No bills available'),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          paymentData.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paymentData.length,
                  itemBuilder: (context, index) {
                    final payment = paymentData[index];
                    return GestureDetector(
                      onTap: () {
                        // Show an Alert Dialog with payment details
                        _showPaymentDetailsDialog(context, payment);
                      },
                      child: _buildPaymentInfoBox('Payment', payment),
                    );
                  },
                )
              : const Text('No payments available'),
        ],
      ),
    );
  }

// Function to show payment details in an AlertDialog
  void _showPaymentDetailsDialog(
      BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('Payment ID:', payment['paymentId'] ?? 'N/A'),
              _buildDataRow('Payment Date:', payment['paymentDate'] ?? 'N/A'),
              _buildDataRow('Amount:',
                  'Rs. ${(payment['enteredAmount'] ?? 0.0).toStringAsFixed(2)}'),
              _buildDataRow('Payment Mode:', payment['paymentMode'] ?? 'N/A'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoBox(String title, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'Rs. ${(data['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$title Number: ${data['billNumber'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDataRow('Bill Date:', data['billDate'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoBox(String title, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'Rs. ${(data['enteredAmount'] ?? 0.0).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$title ID: ${data['paymentId'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDataRow('Payment Date:', data['paymentDate'] ?? 'N/A'),
          _buildDataRow('Payment Mode:', data['paymentMode'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}
