import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';

// Example Option Pages
class UnitMasterScreen extends StatelessWidget {
  const UnitMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(
        title: 'Unit Master',
        isMenu: false,
      ),
      body: Center(child: Text('This is Unit Master')),
    );
  }
}
