import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/customer_credit_screens/customer_credits.dart';
import 'package:galaxy_mini/screens/details_screens/sync_data.dart';
import 'package:galaxy_mini/screens/inventory_screens/inventory_head_screen.dart';
import 'package:galaxy_mini/screens/report_screens/report_main_screens.dart';
import 'package:galaxy_mini/screens/setting_screens/settings_screen.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/upcoming_order.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  late SyncProvider syncProvider;
  @override
  void initState() {
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    super.initState();
  }

  final bool upcomingOrders = true;
  final bool reports = true;
  final bool customerCredits = true;
  final bool inventory = true;

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
          if (upcomingOrders)
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
          if (reports)
            ListTile(
              leading: const Icon(Icons.insert_chart, color: AppColors.blue),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportSceens()),
                );
              },
            ),
          if (customerCredits)
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
          if (inventory)
            ListTile(
              leading: const Icon(Icons.inventory, color: AppColors.blue),
              title: const Text('Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InventoryHeadScreen()),
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
          // ListTile(
          //   leading: const Icon(Icons.logout, color: AppColors.blue),
          //   title: const Text('Logout'),
          //   onTap: () async {
          //     await Provider.of<SyncProvider>(context, listen: false)
          //         .logout(context);
          //     // Navigator.pop(context);
          //     // Navigator.pushReplacement(
          //     //   context,
          //     //   MaterialPageRoute(builder: (context) => const LoginScreen()),
          //     // );
          //   },
          // ),
        ],
      ),
    );
  }
}
