import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class CustomerwiseReportScreen extends StatefulWidget {
  const CustomerwiseReportScreen({super.key});

  @override
  State<CustomerwiseReportScreen> createState() =>
      _CustomerwiseReportScreenState();
}

class _CustomerwiseReportScreenState extends State<CustomerwiseReportScreen> {
  // TODO: Remove this Static data after implementing API
  final List<Map<String, String>> _data = [
    {
      '': '1',
      'billNo': '1',
      'totalItems': '100.0',
      'totalAmount': '2000.0',
      'orderDate': '{date, time}',
      'payment': 'Cash',
      'status': 'Cancelled',
      'code': '1',
      'customerCode': '-',
      'customerName': '-',
    },
    {
      '': '2',
      'billNo': '3',
      'totalItems': '100.0',
      'totalAmount': '2000.0',
      'orderDate': '{date, time}',
      'payment': 'Cash',
      'status': 'Cancelled',
      'code': '1',
      'customerCode': '-',
      'customerName': '-',
    },
  ];

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
                          _buildHeaderCell('Status'),
                          _buildHeaderCell('Code'),
                          _buildHeaderCell('Customer Code'),
                          _buildHeaderCell('Customer Name'),
                        ],
                      ),
                      // Data rows from _data
                      for (var rowData in _data)
                        TableRow(
                          children: [
                            _buildDataCell(rowData['']!),
                            _buildDataCell(rowData['billNo']!),
                            _buildDataCell(rowData['totalItems']!),
                            _buildDataCell(rowData['totalAmount']!),
                            _buildDataCell(rowData['orderDate']!),
                            _buildDataCell(rowData['payment']!),
                            _buildDataCell(rowData['status']!),
                            _buildDataCell(rowData['code']!),
                            _buildDataCell(rowData['customerCode']!),
                            _buildDataCell(rowData['customerName']!),
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
}
