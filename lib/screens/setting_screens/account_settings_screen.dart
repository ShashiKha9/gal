import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/change_login_user_dialog.dart';
import 'package:galaxy_mini/components/change_pass_dialog.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/auth/login.dart';
import 'package:galaxy_mini/screens/setting_screens/manage_login_user/manage_login_user.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Account Setting',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textRow('User ID:', '04'),
                  _textRow('User Name:', 'test1'),
                  _textRow('License Date:', 'N/A'),
                  _textRow('Validity:', '130 days'),
                ],
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.key,
            title: 'Manage Login User',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageLoginUser()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: 'Change Login User',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ChangeLoginUserDialog();
                },
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.key,
            title: 'Change Password',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ChangePasswordDialog();
                },
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
        onTap: onTap,
      ),
    );
  }

  Widget _textRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> showLogoutDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you really want to Logout?'),
          content: const Text(
            'If you logout, internal storage data should be deleted.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<SyncProvider>(context, listen: false)
                    .logout(context);

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
