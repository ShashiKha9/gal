import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/models/customer_model.dart';
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
  String searchQuery = '';
  List<CustomerModel> filteredCustomerList = [];

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _syncProvider.loadCustomerListFromPrefs().then((value) {
      filteredCustomerList = _syncProvider.customerList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
          title: 'Customer Master',
          isSearch: true,
          onSearch: (query) {
            if (query == null || query.isEmpty) {
              setState(() {
                filteredCustomerList = _syncProvider.customerList;
              });
            } else {
              setState(() {
                searchQuery = query.toLowerCase(); // Update search query
              });
            }
          }),
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
        // Check if the customer list is loaded
        if (syncProvider.customerList.isEmpty) {
          return const Center(child: Text('No customers available.'));
        }

        // Filter the customer list based on the search query
        final filteredList = syncProvider.customerList.where((customer) {
          final customerName = customer.name?.toLowerCase() ?? '';
          return customerName.contains(searchQuery);
        }).toList();

        log(filteredList.length.toString(),
            name: 'Filtered customer list length');

        // Check if the filtered list is empty
        if (filteredList.isEmpty) {
          return const Center(
              child: Text('No customers found matching the search.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final customer = filteredList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
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
                          customerName: customer.name ?? '',
                          customerMobile: customer.mobile1 ?? '',
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

  // New search function
  void _filterCustomers(String? query) {
    if (query == null || query.isEmpty) {
      setState(() {
        filteredCustomerList = _syncProvider.customerList;
      });
    } else {
      setState(() {
        filteredCustomerList = _syncProvider.customerList.where((customer) {
          return customer.name!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }
}
