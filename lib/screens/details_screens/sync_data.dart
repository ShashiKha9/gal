import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/components/scaffold_message.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class SyncData extends StatelessWidget {
  const SyncData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Sync Data',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildListTile(
            context,
            icon: Icons.sync,
            title: 'Fetch master data from server',
            onTap: () async {
              // Trigger API calls using SyncProvider
              final syncProvider =
                  Provider.of<SyncProvider>(context, listen: false);
              final upcomingprovider =
                  Provider.of<UpcomingOrderProvider>(context, listen: false);
              final parkprovider =
                  Provider.of<ParkedOrderProvider>(context, listen: false);
              await syncProvider.getDepartmentsAll();
              await syncProvider.getItemsAll();
              await syncProvider.getTableMasterAll();
              await syncProvider.getKotGroupAll();
              await syncProvider.getTaxAll();
              await syncProvider.getCustomerAll();
              await syncProvider.getPaymentAll();
              await syncProvider.getOfferAll();
              await syncProvider.getKotMessageAll();
              await upcomingprovider.loadOrders();
              await parkprovider.loadParkedOrders();

              if (context.mounted) {
                scaffoldMessage(message: "Data synchronized successfully!");
              }
            },
          ),
          _buildListTile(
            context,
            icon: Icons.sync,
            title: 'Fetch store stock from server',
            onTap: () {
              // Add functionality here for fetching store stock
            },
          ),
          _buildListTile(
            context,
            icon: Icons.sync,
            title: 'Fetch customer credit from server',
            onTap: () async {
              Navigator.pop(context);

              final customerprovider =
                  Provider.of<CustomerCreditProvider>(context, listen: false);

              // Fetch customer codes from SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              List<String>? customerCodes =
                  prefs.getStringList('customer_codes');

              if (customerCodes != null && customerCodes.isNotEmpty) {
                // Loop through customer codes and fetch their bill data
                for (String customerCode in customerCodes) {
                  await customerprovider.loadBillData(customerCode);
                }

                // After syncing, set the flag to indicate data is fetched
                await prefs.setBool('is_customer_credit_fetched', true);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Customer credit data synchronized!')),
                );
              }
            },
          ),
          _buildListTile(
            context,
            icon: Icons.upload,
            title: 'Upload data to server',
            onTap: () {
              // Add functionality here for uploading data
            },
          ),
          _buildListTile(
            context,
            icon: Icons.cloud_upload,
            title: 'Upload full data to server',
            onTap: () {
              // Add functionality here for uploading full data
            },
          ),
          _buildListTile(
            context,
            icon: Icons.backup,
            title: 'Backup data to local storage',
            onTap: () {
              // Add functionality here for backing up data
            },
          ),
          _buildListTile(
            context,
            icon: Icons.clear,
            title: 'Clear bills',
            onTap: () {
              // Add functionality here for clearing bills
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: AppButton(
              buttonText: 'Remove duplicate customers',
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
}
