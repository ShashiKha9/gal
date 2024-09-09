import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/master_setting.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.greenTwo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Master settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MasterSettingPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Printer settings'),
            onTap: () {
              // Placeholder for navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Bill settings'),
            onTap: () {
              // Placeholder for navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Account Setting'),
            onTap: () {
              // Placeholder for navigation
            },
          ),
        ],
      ),
    );
  }
}
