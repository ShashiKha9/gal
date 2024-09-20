import 'package:flutter/material.dart';

class BillSettingsScreen extends StatefulWidget {
  const BillSettingsScreen({super.key});

  @override
  State<BillSettingsScreen> createState() => _BillSettingsScreenState();
}

class _BillSettingsScreenState extends State<BillSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Bill Settings"),
      ),
    );
  }
}
