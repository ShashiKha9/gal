import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/customer_credit_screens/bill_detail.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/utils/extension.dart';
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
  String lastBillDate = 'N/A'; // Initialize with a default value
  String lastPaymentDate = 'N/A';

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

// Import the intl package at the top of your file

  Future<void> _loadData() async {
    final creditProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);

    billData = await creditProvider.loadBillData(widget.customerCode);
    paymentData = await creditProvider.loadPaymentData(widget.customerCode);

    // Set the latest bill number, bill date, payment ID, and payment date
    if (billData.isNotEmpty) {
      final lastBill = billData.last;
      currentBillNumber = lastBill['billNumber'].toString();

      // Parse the last bill date using intl package
      lastBillDate = DateFormat("dd, MMM yyyy, hh:mm a").format(
        DateFormat("dd, MMM yyyy, hh:mm a").parse(lastBill['billDate']),
      );
    }

    if (paymentData.isNotEmpty) {
      final lastPayment = paymentData.last;
      currentPaymentId = lastPayment['paymentId'].toString();

      // Parse the last payment date using intl package
      lastPaymentDate = DateFormat("dd, MMM yyyy, hh:mm a").format(
        DateFormat("dd, MMM yyyy, hh:mm a").parse(lastPayment['paymentDate']),
      );
    }

    currentBalance = _calculateCurrentBalance();
    setState(() {});
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
  void _makePaymentDialog(
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

    // Get the current date in the desired format using your custom method
    String paymentDate =
        toStandardDtTime(); // Call your custom method to format date

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
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
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
                TextButton(
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

// Your toStandardDtTime method
  String toStandardDtTime() {
    // Get the current date in UTC and convert to local time
    DateTime localDateTime =
        DateTime.now(); // Assuming this is your current local time

    // Extract date and time components
    int hour = localDateTime.hour;
    int minute = localDateTime.minute;
    int day = localDateTime.day;
    int month = localDateTime.month;
    int year = localDateTime.year;

    // Convert to 12-hour format
    int hour0 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Format the date and time
    return '${day < 10 ? '0$day' : day}, ${month.intToMonth()} $year, '
        '${hour0 < 10 ? '0$hour0' : hour0}:${minute < 10 ? '0$minute' : minute} '
        '${hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Customer Credit Details',
      ),
      body: billData.isEmpty && paymentData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _customerInfo(),
                    _choiceChips(),
                    if (selectedChip == 'All') _allDataList(),
                    if (selectedChip == 'Bills') _billList(),
                    if (selectedChip == 'Payments') _paymentList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _makePaymentDialog(
            context, syncProvider, creditProvider,
            widget.customerCode, // Pass the customer code
            widget.customerName,
          );
        },
        child: const Icon(Icons.payment),
      ),
    );
  }

  Widget _customerInfo() {
    // Access SyncProvider using Provider.of
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    // Find the customer in customerList using the customerCode
    String? mobileNumber;
    for (var customer in syncProvider.customerList) {
      if (customer.customerCode == widget.customerCode) {
        mobileNumber = customer.mobile1 ?? 'N/A'; // Fetch mobile1 if available
        break;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display dynamic mobileNumber fetched from SyncProvider
                Text(
                  "${widget.customerName} - $mobileNumber",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "₹ $currentBalance",
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              "Customer Code - #${widget.customerCode}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Last Bill - ${currentBillNumber.isNotEmpty ? currentBillNumber : 'N/A'} (Date: $lastBillDate)",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Last Payment - ${currentPaymentId.isNotEmpty ? currentPaymentId : 'N/A'} (Date: $lastPaymentDate)",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New widget to build choice chips for filtering
  Widget _choiceChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ChoiceChip(
            label: Text(
              'All',
              style: TextStyle(
                color: selectedChip == 'All' ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: selectedChip == 'All',
            onSelected: (selected) {
              setState(() {
                selectedChip = 'All';
              });
            },
            avatar: null,
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(
              'Bills',
              style: TextStyle(
                color: selectedChip == 'Bills' ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: selectedChip == 'Bills',
            onSelected: (selected) {
              setState(() {
                selectedChip = 'Bills';
              });
            },
            avatar: null,
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(
              'Payments',
              style: TextStyle(
                color: selectedChip == 'Payments' ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: selectedChip == 'Payments',
            onSelected: (selected) {
              setState(() {
                selectedChip = 'Payments';
              });
            },
            avatar: null,
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allDataList() {
    return Column(
      children: [
        _billList(),
        _paymentList(),
      ],
    );
  }

  Widget _billList() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Bills:',
          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          // ),
          billData.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: billData.length,
                  itemBuilder: (context, index) {
                    final bill = billData[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillDetailPage(billData: {
                              'billNumber': bill['billNumber'],
                              'billDate': bill['billDate'],
                              'customerName': bill['customerName'],
                              'customerCode': bill['customerCode'],
                              'totalAmount':
                                  (bill['totalAmount'] ?? 0.0).toInt(),
                              'items': bill['items'],
                              'quantities': bill['quantities'],
                              'rates': bill['rates'],
                            }),
                          ),
                        );
                      },
                      child: _billCard('Bill', bill),
                    );
                  },
                )
              : const Text('No bills available'),
        ],
      ),
    );
  }

  Widget _paymentList() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Payments:',
          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          // ),
          paymentData.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paymentData.length,
                  itemBuilder: (context, index) {
                    final payment = paymentData[index];
                    return GestureDetector(
                      onTap: () {
                        _paymentDetailsDialog(context, payment);
                      },
                      child: _paymentCard('Payment', payment),
                    );
                  },
                )
              : const Text('No payments available'),
        ],
      ),
    );
  }

// Function to show payment details in an AlertDialog
  void _paymentDetailsDialog(
      BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Details'),
          content: SizedBox(
            width: 800,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textRow('Payment ID:', payment['paymentId'] ?? 'N/A'),
                _textRow('Payment Date:', payment['paymentDate'] ?? 'N/A'),
                _textRow('Amount:',
                    'Rs. ${(payment['enteredAmount'] ?? 0.0).toStringAsFixed(2)}'),
                _textRow('Payment Mode:', payment['paymentMode'] ?? 'N/A'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _billCard(String title, Map<String, dynamic> data) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title Number: ${data['billNumber'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${(data['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _textRow('Bill Date:', data['billDate'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(String title, Map<String, dynamic> data) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title ID: ${data['paymentId'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${(data['enteredAmount'] ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _textRow('Payment Date:', data['paymentDate'] ?? 'N/A'),
            _textRow('Payment Mode:', data['paymentMode'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _textRow(String label, String value, {Color? textColor}) {
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
