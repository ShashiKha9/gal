import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/report_screens/report_detail_screen.dart';
import 'package:galaxy_mini/screens/report_screens/report_main_screens.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class BillwiseReportScreen extends StatefulWidget implements ReportSceens {
  const BillwiseReportScreen({super.key});

  @override
  State<BillwiseReportScreen> createState() => _BillwiseReportScreenState();
}

class _BillwiseReportScreenState extends State<BillwiseReportScreen> {
  // TODO: Remove this Static data after implementing API
  final List<Map<String, String>> _data = [
    {
      '': '1',
      'billNo': '2',
      'totalItems': '100.0',
      'totalAmount': '2000.0',
      'orderDate': '{date, time}',
      'payment': 'Cash',
      'code': '1',
      'customerCode': '-',
      'customerName': '-',
    },
    {
      '': '2',
      'billNo': '4',
      'totalItems': '50.0',
      'totalAmount': '5000.0',
      'orderDate': '{date, time}',
      'payment': 'Card',
      'code': '1',
      'customerCode': '-',
      'customerName': '-',
    },
    {
      '': '3',
      'billNo': '5',
      'totalItems': '20.0',
      'totalAmount': '1000.0',
      'orderDate': '{date, time}',
      'payment': 'UPI',
      'code': '1',
      'customerCode': '-',
      'customerName': '-',
    },
    {
      '': '4',
      'billNo': '7',
      'totalItems': '100.0',
      'totalAmount': '2000.0',
      'orderDate': '{date, time}',
      'payment': 'Cash',
      'code': '1',
      'customerCode': '-',
      'customerName': '-',
    },
  ];

  bool hasData() => _data.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    border: TableBorder.all(
                      color: AppColors.lightGrey,
                      width: 1.0,
                    ),
                    children: [
                      // Table header row
                      TableRow(
                        decoration:
                            const BoxDecoration(color: AppColors.lightPink),
                        children: [
                          _buildHeaderCell(''),
                          _buildHeaderCell('Bill No.'),
                          _buildHeaderCell('Total Items'),
                          _buildHeaderCell('Total Amount'),
                          _buildHeaderCell('Order Date'),
                          _buildHeaderCell('Payment'),
                          _buildHeaderCell('Code'),
                          _buildHeaderCell('Customer Code'),
                          _buildHeaderCell('Customer Name'),
                        ],
                      ),
                      // Data rows from _data
                      for (var rowData in _data)
                        TableRow(
                          children: [
                            _buildDataCell(rowData['']!, context),
                            _buildDataCell(rowData['billNo']!, context),
                            _buildDataCell(rowData['totalItems']!, context),
                            _buildDataCell(rowData['totalAmount']!, context),
                            _buildDataCell(rowData['orderDate']!, context),
                            _buildDataCell(rowData['payment']!, context),
                            _buildDataCell(rowData['code']!, context),
                            _buildDataCell(rowData['customerCode']!, context),
                            _buildDataCell(rowData['customerName']!, context),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  static TableCell _buildDataCell(String text, BuildContext context) {
    return TableCell(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportDetailScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
