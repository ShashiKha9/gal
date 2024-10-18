import 'package:flutter/material.dart';

class ItemwiseReportScreen extends StatefulWidget {
  const ItemwiseReportScreen({super.key});

  @override
  State<ItemwiseReportScreen> createState() => _ItemwiseReportScreenState();
}

class _ItemwiseReportScreenState extends State<ItemwiseReportScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Itemwise Screen")),
    );
  }
}
