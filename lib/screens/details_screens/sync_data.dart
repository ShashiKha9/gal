import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class SyncData extends StatelessWidget {
  const SyncData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
        backgroundColor: const Color(0xFFC41E3A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Fetch master data from server'),
              leading: const Icon(Icons.sync),
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
            const Divider(),
            ListTile(
              title: const Text('Fetch store stock from server'),
              leading: const Icon(Icons.sync),
              onTap: () {
                // Add functionality here for fetching store stock
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Fetch customer credit from server'),
              leading: const Icon(Icons.sync),
              onTap: () {
                // Add functionality here for fetching customer credit
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Upload data to server'),
              leading: const Icon(Icons.upload),
              onTap: () {
                // Add functionality here for uploading data
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Upload full data to server'),
              leading: const Icon(Icons.cloud_upload),
              onTap: () {
                // Add functionality here for uploading full data
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Backup data to local storage'),
              leading: const Icon(Icons.backup),
              onTap: () {
                // Add functionality here for backing up data
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Clear bills'),
              leading: const Icon(Icons.clear),
              onTap: () {
                // Add functionality here for clearing bills
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC41E3A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  // Add functionality to remove duplicate customers
                },
                child: const Text(
                  'Remove duplicate customers',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
