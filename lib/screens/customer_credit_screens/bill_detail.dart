import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';

class BillDetailPage extends StatelessWidget {
  final Map<String, dynamic> billData;

  const BillDetailPage({super.key, required this.billData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Bill Detail',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBillInfo(),
            const SizedBox(height: 10),
            const Divider(thickness: 2),
            _buildItemList(),
            const Divider(thickness: 2),
            _buildTotalAmount(),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            _buildPrintButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillInfo() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textRow('Bill Number:', ' ${billData['billNumber']}'),
            _textRow('Bill Date:', ' ${billData['billDate']}'),
            _textRow('Customer Name:', ' ${billData['customerName']}'),
            _textRow('Bill Code:', ' ${billData['customerCode']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    if (billData['items'] == null || billData['items'].isEmpty) {
      return const Center(child: Text('No items available.'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Item Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Rate',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Price',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
                    child: Text(
                      quantity.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '₹ ${rate.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '₹ ${price.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
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
      padding: const EdgeInsets.all(0),
      child: Text(
        'Total Amount: ₹ ${total.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildPrintButton() {
    return AppButton(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      onTap: () {
        // Implement print functionality here
      },
      buttonText: 'Print',
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
