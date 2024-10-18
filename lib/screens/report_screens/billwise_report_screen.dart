import 'package:flutter/material.dart';

class BillwiseReportScreen extends StatefulWidget {
  const BillwiseReportScreen({super.key});

  @override
  State<BillwiseReportScreen> createState() => _BillwiseReportScreenState();
}

class _BillwiseReportScreenState extends State<BillwiseReportScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Billwise Screen")),
    );
  }
}
