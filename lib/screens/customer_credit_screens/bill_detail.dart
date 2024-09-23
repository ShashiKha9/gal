import 'package:flutter/material.dart';

class BillDetailPage extends StatelessWidget {
  final Map<String, dynamic> billData;

  const BillDetailPage({super.key, required this.billData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBillInfo(),
            const Divider(thickness: 2),
            _buildItemList(),
            const Divider(thickness: 2),
            _buildTotalAmount(),
            const Divider(thickness: 2),
            _buildPrintButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bill Number: ${billData['billNumber']}'),
        Text('Bill Date: ${billData['billDate']}'),
        Text('Customer Name: ${billData['customerName']}'),
        Text('Customer Code: ${billData['customerCode']}'),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemList() {
    if (billData['items'] == null || billData['items'].isEmpty) {
      return const Center(child: Text('No items available.'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Text('Item Name',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('Rate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('Price',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(thickness: 2),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: billData['items'].length,
          itemBuilder: (context, itemIndex) {
            final item = billData['items'][itemIndex];
            String itemName = item['name'];
            double quantity = billData['quantities'][itemName] ?? 0.0;
            double rate = billData['rates'][itemName] ?? 0.0;
            double price = quantity * rate;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(itemName,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 1,
                      child: Text(quantity.toString(),
                          textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text('₹ ${rate.toStringAsFixed(2)}',
                          textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text('₹ ${price.toStringAsFixed(2)}',
                          textAlign: TextAlign.center)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    double total = 0.0;
    billData['items'].forEach((item) {
      String itemName = item['name'];
      double quantity = billData['quantities'][itemName] ?? 0.0;
      double rate = billData['rates'][itemName] ?? 0.0;
      total += quantity * rate;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Total Amount: ₹ ${total.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildPrintButton() {
    return ElevatedButton(
      onPressed: () {
        // Implement print functionality here
      },
      child: const Text('Print'),
    );
  }
}
