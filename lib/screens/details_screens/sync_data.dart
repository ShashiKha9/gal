import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class SyncData extends StatefulWidget {
  const SyncData({super.key});

  @override
  State<SyncData> createState() => _SyncDataState();
}

class _SyncDataState extends State<SyncData> {
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const SyncDataDialog();
                },
              );
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
              // final customerprovider =
              //     Provider.of<CustomerCreditProvider>(context, listen: false);

              // // Fetch customer codes from SharedPreferences
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // List<String>? customerCodes =
              //     prefs.getStringList('customer_codes');

              // if (customerCodes != null && customerCodes.isNotEmpty) {
              //   // Loop through customer codes and fetch their bill data
              //   for (String customerCode in customerCodes) {
              //     await customerprovider
              //         .loadBillData(customerCode)
              //         .then((value) {
              //       scaffoldMessage(
              //           message: "Customer credit data synchronized!");
              //       Navigator.pop(context);
              //     });
              //   }

              //   // After syncing, set the flag to indicate data is fetched
              //   await prefs.setBool('is_customer_credit_fetched', true);
              // }
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              buttonText: 'Remove duplicate customers',
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
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        onTap: onTap,
      ),
    );
  }
}

class SyncDataDialog extends StatefulWidget {
  const SyncDataDialog({super.key});

  @override
  State<SyncDataDialog> createState() => _SyncDataDialogState();
}

class _SyncDataDialogState extends State<SyncDataDialog> {
  List<String> statusMessages = ['Initializing...'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _syncData();
  }

  Future<void> _syncData() async {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    final upcomingProvider =
        Provider.of<UpcomingOrderProvider>(context, listen: false);
    final parkProvider =
        Provider.of<ParkedOrderProvider>(context, listen: false);

    try {
      // Initialize a helper function for updates
      Future<void> updateStatus(String message) async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          statusMessages.add(message);
        });
      }

      // Sequentially fetch data and update status
      await updateStatus('Fetching Departments...');
      await syncProvider.getDepartmentsAll();

      await updateStatus('Fetching Items...');
      await syncProvider.getItemsAll();

      await updateStatus('Fetching Table Master...');
      await syncProvider.getTableMasterAll();

      await updateStatus('Fetching Table Group...');
      await syncProvider.getTableGroupAll();

      await updateStatus('Fetching Kot Group...');
      await syncProvider.getKotGroupAll();

      await updateStatus('Fetching Taxes...');
      await syncProvider.getTaxAll();

      await updateStatus('Fetching Customers...');
      await syncProvider.getCustomerAll();

      await updateStatus('Fetching Payment Methods...');
      await syncProvider.getPaymentAll();

      await updateStatus('Fetching Offers...');
      await syncProvider.getOfferAll();

      await updateStatus('Fetching Kot Messages...');
      await syncProvider.getKotMessageAll();

      await updateStatus('Fetching Upcoming Orders...');
      await upcomingProvider.loadOrders();

      await updateStatus('Fetching Parked Orders...');
      await parkProvider.loadParkedOrders();

      await updateStatus('Fetching Units...');
      await syncProvider.getUnitsAll();

      // Set final success status
      setState(() {
        statusMessages.add('Data synchronized successfully!');
        isLoading = false; // Allow closing the dialog
      });

      // Close dialog after a short delay
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      // Set error status if any API call fails
      setState(() {
        statusMessages.add('Error occurred during synchronization!');
        isLoading = false; // Allow closing the dialog
      });

      // Close dialog after a short delay
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Synchronizing Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          // Display dynamic status
          Text(statusMessages.join('\n')),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: isLoading
              ? null // Disable button while loading
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Close'), // Changed to 'Close'
        ),
      ],
    );
  }
}
