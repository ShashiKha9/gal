import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/theme/font_theme.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final List<Map<String, String>> _data = [
    {
      'ItemName': 'Adult T-Shirt',
      'Qty': '100.0',
      'Rate': '₹ 199.0',
      'Price': '₹ 19900.00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // You can wrap the buttons in `Expanded` to make them flexible
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    viewSummaryDetails(),
                    printDownload(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Bill No.:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                " 3",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          _infoTextRow('Table No.:', " 999"),
                          _infoTextRow('Bill Date:', " {date, time}"),
                          _infoTextRow('Customer Name:', " N/A"),
                          _infoTextRow('Payment Mode:', " Cash"),
                        ],
                      ),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          "CANCEL ORDER",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    border: TableBorder.all(
                      color: AppColors.lightGrey,
                      width: 1.0,
                    ),
                    children: [
                      TableRow(
                        decoration:
                            const BoxDecoration(color: AppColors.lightPink),
                        children: [
                          _buildHeaderCell('Item Name'),
                          _buildHeaderCell('Qty'),
                          _buildHeaderCell('Rate'),
                          _buildHeaderCell('Price'),
                        ],
                      ),
                      for (var rowData in _data)
                        TableRow(
                          children: [
                            _buildDataCell(rowData['ItemName']!),
                            _buildDataCell(rowData['Qty']!),
                            _buildDataCell(rowData['Rate']!),
                            _buildDataCell(rowData['Price']!),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static TableCell _buildHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static TableCell _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Column viewSummaryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 2),
        _textRow('SubTotal:', "₹ 19900.0"),
        _textRow('CGST:', "₹ 0.0"),
        _textRow('SGST:', "₹ 0.0"),
        _textRow('IGST:', "₹ 0.0"),
        _textRow('Round off:', "₹ 0.0"),
        _textRow('Discount:', "₹ 0.0"),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total Amount:",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹ 19900.00",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Row printDownload() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          buttonText: "Print Bill",
          padding: const EdgeInsets.symmetric(horizontal: 30),
          onTap: () {},
        ),
        AppButton(
          buttonText: "Close",
          backgroundColor: Colors.grey,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _textRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
          ),
          Text(
            value,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _infoTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(label, style: normalBlack),
          Text(value, style: normalBlack),
        ],
      ),
    );
  }
}
