import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/auth/login.dart';
import 'package:galaxy_mini/screens/customer_credit_screens/customer_credits.dart';
import 'package:galaxy_mini/screens/details_screens/sync_data.dart';
import 'package:galaxy_mini/screens/setting_screens/settings_screen.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/upcoming_order.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.lightPink,
            ),
            child: Text(
              "GalaxyMini",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: AppColors.blue),
            title: const Text('Upcoming orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpcomingOrdersPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart, color: AppColors.blue),
            title: const Text('Reports'),
            onTap: () {
              // Navigator.pop(context);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => CreditPartyDataPage()),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card, color: AppColors.blue),
            title: const Text('Customer Credits'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomerCredits()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync, color: AppColors.blue),
            title: const Text('Sync data'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SyncData()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.blue),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.blue),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
