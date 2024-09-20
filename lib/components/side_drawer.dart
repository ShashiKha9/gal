import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/customer_credits.dart';
import 'package:galaxy_mini/screens/settings.dart';
import 'package:galaxy_mini/provider/sync_provider.dart'; // Import SyncProvider
import 'package:galaxy_mini/screens/upcoming_order.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart'; // Import Provider

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
              color: AppColors.greenTwo,
            ),
            child: Text('Menu'),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
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
            leading: const Icon(Icons.insert_chart),
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
            leading: const Icon(Icons.credit_card),
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
            leading: const Icon(Icons.sync),
            title: const Text('Sync data'),
            onTap: () async {
              // Close the drawer
              Navigator.pop(context);

              // Trigger API calls using SyncProvider
              final syncProvider =
                  Provider.of<SyncProvider>(context, listen: false);

              // Perform the API calls
              await syncProvider.getDepartmentsAll();
              await syncProvider.getItemsAll();
              await syncProvider.getTableMasterAll();
              await syncProvider.getKotGroupAll();
              await syncProvider.getTaxAll();
              await syncProvider.getCustomerAll();
              await syncProvider.getPaymentAll();
              await syncProvider.getOfferAll();
              await syncProvider.getOfferAll();
              await syncProvider.getKotMessageAll();

              // Check if the widget is still mounted before calling Navigator.pop
              if (context.mounted) {
                // Optionally show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Data synchronized successfully!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
