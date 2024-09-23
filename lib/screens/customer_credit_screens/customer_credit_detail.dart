import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/screens/customer_credit_screens/bill_detail.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
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
                  _buildBillList(),
                  const SizedBox(height: 16),
                  _buildPaymentList(),
                ],
              ),
            ),
    );
  }

  // Widget to display customer code, name, bill number, payment ID, and current balance
  Widget _buildCustomerInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataRow('Customer Name:', widget.customerName),
          _buildDataRow('Customer Code:', widget.customerCode),
          _buildDataRow('Latest Bill Number:',
              currentBillNumber.isNotEmpty ? currentBillNumber : 'N/A'),
          _buildDataRow('Latest Payment ID:',
              currentPaymentId.isNotEmpty ? currentPaymentId : 'N/A'),
          _buildDataRow(
            'Current Balance:',
            'Rs. ${currentBalance.toStringAsFixed(2)}',
            textColor: Colors.red,
          ),
        ],
      ),
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
                    return _buildPaymentInfoBox('Payment', payment);
                  },
                )
              : const Text('No payments available'),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Number: ${data['billNumber'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDataRow('Bill Date:', data['billDate'] ?? 'N/A'),
          _buildDataRow('Customer Name:', data['customerName'] ?? 'N/A'),
          _buildDataRow('Customer Code:', data['customerCode'] ?? 'N/A'),
          _buildDataRow(
            'Total Amount:',
            'Rs. ${(data['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
          ),
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
          Text(
            '$title ID: ${data['paymentId'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDataRow('Payment Date:', data['paymentDate'] ?? 'N/A'),
          _buildDataRow('Customer Name:', data['customerName'] ?? 'N/A'),
          _buildDataRow('Customer Code:', data['customerCode'] ?? 'N/A'),
          _buildDataRow('Payment Mode:', data['paymentMode'] ?? 'N/A'),
          _buildDataRow(
            'Entered Amount:',
            'Rs. ${(data['enteredAmount'] ?? 0.0).toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(color: textColor)), // Apply textColor here
        ],
      ),
    );
  }
}

// Custom reusable Card widget
class CustomCard extends StatelessWidget {
  final Widget child;

  const CustomCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[50], // Set a common background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
