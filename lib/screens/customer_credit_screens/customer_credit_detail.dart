import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load all bills and payments for the customer
    final creditProvider =
        Provider.of<CustomerCreditProvider>(context, listen: false);
    
    // Load all bills and payments for this specific customer
    billData = await creditProvider.loadBillData(widget.customerCode);
    paymentData = await creditProvider.loadPaymentData(widget.customerCode);

    setState(() {}); // Update the UI after data is loaded
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
            ) // Show loading indicator while data is being fetched
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBillList(),
                  const SizedBox(height: 16),
                  _buildPaymentList(),
                ],
              ),
            ),
    );
  }

  // Widget to display the list of bills
  Widget _buildBillList() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    shrinkWrap: true, // Prevent ListView from expanding infinitely
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: billData.length,
                    itemBuilder: (context, index) {
                      final bill = billData[index];
                      return _buildInfoBox('Bill', bill);
                    },
                  )
                : const Text('No bills available'),
          ],
        ),
      ),
    );
  }

  // Widget to display the list of payments
  Widget _buildPaymentList() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    shrinkWrap: true, // Prevent ListView from expanding infinitely
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

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
