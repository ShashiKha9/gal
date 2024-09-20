import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/account_settings.dart';
import 'package:galaxy_mini/screens/bill_settings.dart';
import 'package:galaxy_mini/screens/master_setting.dart';
import 'package:galaxy_mini/screens/printer_settings.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Settings',
        isMenu: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildListTile(
            context,
            icon: Icons.security,
            title: 'Master settings',
            page: const MasterSettingPage(),
          ),
          _buildListTile(
            context,
            icon: Icons.notifications,
            title: 'Printer settings',
            page: const PrinterSettings(),
          ),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'Bill settings',
            page: const BillSettings(),
          ),
          _buildListTile(
            context,
            icon: Icons.info,
            title: 'Account Setting',
            page: const AccountSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
