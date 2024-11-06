import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class DepartmentwiseReportScreen extends StatefulWidget {
  const DepartmentwiseReportScreen({super.key});

  @override
  State<DepartmentwiseReportScreen> createState() =>
      _DepartmentwiseReportScreenState();
}

class _DepartmentwiseReportScreenState
    extends State<DepartmentwiseReportScreen> {
  // TODO: Remove this Static data after implementing API
  final List<Map<String, String>> _data = [
    {
      '': '1',
      'Department': 'Shirts',
      'Qty': '10.0',
      'Amount': '2490.0',
    },
    {
      '': '2',
      'Department': 'T-shirts',
      'Qty': '50.0',
      'Amount': '5490.0',
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
                      TableRow(
                        decoration:
                            const BoxDecoration(color: AppColors.lightPink),
                        children: [
                          _buildHeaderCell(''),
                          _buildHeaderCell('Department'),
                          _buildHeaderCell('Qty'),
                          _buildHeaderCell('Amount'),
                        ],
                      ),
                      for (var rowData in _data)
                        TableRow(
                          children: [
                            _buildDataCell(rowData['']!),
                            _buildDataCell(rowData['Department']!),
                            _buildDataCell(rowData['Qty']!),
                            _buildDataCell(rowData['Amount']!),
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
