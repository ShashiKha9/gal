import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class BillDetailPage extends StatefulWidget {
  final Map<String, dynamic> billData;

  const BillDetailPage({super.key, required this.billData});

  @override
  _BillDetailPageState createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  late SyncProvider syncProvider;

  @override
  void initState() {
    super.initState();
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    syncProvider.getTaxAll(); // Fetch tax details from backend
  }

  double _calculateTotalWithTax(double subTotal) {
    // Fetch tax values, ensuring to handle potential nulls or empty values
    double cgst = double.tryParse(syncProvider.taxList.first.cGst) ?? 0.0;
    double sgst = double.tryParse(syncProvider.taxList.first.sgst) ?? 0.0;
    double igst = double.tryParse(syncProvider.taxList.first.iGst) ?? 0.0;

    // Calculate total tax
    double totalTax = (cgst + sgst + igst);

    // Return the total amount including tax
    return subTotal + subTotal * (totalTax / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Bill Detail',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _textRow('Bill Number:', ' ${widget.billData['billNumber']}'),
            _textRow('Bill Date:', ' ${widget.billData['billDate']}'),
            _textRow('Customer Name:', ' ${widget.billData['customerName']}'),
            _textRow('Bill Code:', ' ${widget.billData['customerCode']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    if (widget.billData['items'] == null || widget.billData['items'].isEmpty) {
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
          itemCount: widget.billData['items'].length,
          itemBuilder: (context, itemIndex) {
            final item = widget.billData['items'][itemIndex];
            String itemName = item['name'];
            double quantity = widget.billData['quantities'][itemName] ?? 0.0;
            double rate = widget.billData['rates'][itemName] ?? 0.0;
            double price = quantity * rate;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
    double subTotal = 0.0;
    widget.billData['items'].forEach((item) {
      String itemName = item['name'];
      double quantity = widget.billData['quantities'][itemName] ?? 0.0;
      double rate = widget.billData['rates'][itemName] ?? 0.0;
      subTotal += quantity * rate;
    });

    // Calculate total with tax
    double totalWithTax = _calculateTotalWithTax(subTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Left align the text
      children: [
        Text('Sub Total: ₹ ${subTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left),
        const SizedBox(height: 10),
        Text('CGST: ${syncProvider.taxList.first.cGst}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left),
        Text('SGST: ${syncProvider.taxList.first.sgst}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left),
        Text('IGST: ${syncProvider.taxList.first.iGst}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left),
        const SizedBox(height: 10),
        Text('Total Amount: ₹ ${totalWithTax.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold, // Increased font size for the total amount
              color: AppColors.blue,
            ),
            textAlign: TextAlign.left),
      ],
    );
  }

  Widget _buildPrintButton() {
    return AppButton(
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
