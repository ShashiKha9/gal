import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/master_settings_screens/customer_masters/add_new_customer.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CustomerMaster extends StatefulWidget {
  const CustomerMaster({super.key});

  @override
  State<CustomerMaster> createState() => _CustomerMasterState();
}

class _CustomerMasterState extends State<CustomerMaster> {
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Customer Master',
        isSearch: true,
        onSearch: (p0) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewCustomer()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<SyncProvider>(builder: (context, syncProvider, child) {
        log(syncProvider.customerList.length.toString(),
            name: 'Consumer length');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: syncProvider.customerList.length,
          itemBuilder: (context, index) {
            final customer = syncProvider.customerList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                // leading: const Icon(
                //   Icons.person,
                //   color: AppColors.blue,
                // ),
                title: Text(
                  "${customer.customerCode ?? 'no code'} : ${customer.name ?? 'Unnamed'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    // Text(
                    //   'Customer Code: ${customer.customerCode ?? 'no code'}',
                    //   style: const TextStyle(
                    //     fontSize: 14.0,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    // const SizedBox(height: 4.0),
                    Text(
                      'Mobile: ${customer.mobile1 ?? 'no number'}',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddNewCustomer(
                          isEdit: true,
                          customerName: customer.name ??
                              '', // Pass the selected customer name
                          customerMobile: customer.mobile1 ??
                              '', // Pass the selected customer mobile
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: AppColors.blue),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
