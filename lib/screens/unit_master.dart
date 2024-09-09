import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';

// Example Option Pages
class Unitmaster extends StatelessWidget {
  const Unitmaster({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Unit Master',
        onSearch: (p0) {},
      ),
      body: const Center(child: Text('This is Option 1 Page')),
    );
  }
}
