import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart'; // Import the provider
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:provider/provider.dart';
import '../components/main_appbar.dart';

class AddNewItem extends StatefulWidget {
  final String orderId;
  const AddNewItem({super.key, this.isEdit = false, required this.orderId});
  final bool isEdit;

  @override
  _AddNewItemState createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  int _selectedDepartmentIndex = 0;
  String? selectedItemName;
  String? itemName; // Track selected department
  double totalAmount = 0.0;
  Map<String, double> quantities =
      {}; // Enforces integer values for quantities.
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;
  late UpcomingOrderProvider _upcomingOrderProvider; // Add the provider

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _upcomingOrderProvider = Provider.of<UpcomingOrderProvider>(context,
        listen: false); // Initialize provider
    _syncProvider.getDepartmentsAll();
    // Sync data will be triggered from the drawer, so no initial data fetching here
  }

  void _onItemTap(ItemModel item) async {
    setState(() {
      selectedItemName = item.name;

      // Ensure quantities map uses int values
      if (!quantities.containsKey(item.name)) {
        quantities[item.name!] = 1;
      } else {
        quantities[item.name!] = quantities[item.name]! + 1;
      }

      double rate1 = double.tryParse(item.rate1 ?? '0.0') ?? 0.0;
      rates[item.name!] = rate1;

      // Calculate total amount for the current item
      double itemTotalAmount = quantities[item.name!]! * rate1;

      // Store item details using the provider
      _upcomingOrderProvider
          .storeItemDetails(
        item.name!, // Item name
        quantities[item.name!]!.toDouble(), // Quantity
        itemTotalAmount, // Total Amount
        widget.orderId, // Pass OrderId from EditOrder
      )
          .then((_) {
        log('Item added successfully');
      }).catchError((error) {
        log('Failed to add item: $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Department',
        onSearch: (p0) {},
      ),
      body: Consumer<SyncProvider>(builder: (context, syncProvider, child) {
        // Check if the department list is empty, return blank screen if true
        if (syncProvider.departmentList.isEmpty) {
          return const Center(
              child: Text('No departments available. Please sync data.'));
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    List.generate(syncProvider.departmentList.length, (index) {
                  final department = syncProvider.departmentList[index];
                  final isSelected = _selectedDepartmentIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        department.description ?? 'Unnamed',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDepartmentIndex = index;
                        });
                      },
                      selectedColor: const Color(0xFFC41E3A),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1,
                ),
                itemCount: syncProvider
                        .itemsByDepartment[syncProvider
                            .departmentList[_selectedDepartmentIndex].code]
                        ?.length ??
                    0,
                itemBuilder: (context, itemIndex) {
                  final items = syncProvider.itemsByDepartment[syncProvider
                          .departmentList[_selectedDepartmentIndex].code] ??
                      [];
                  final item = items[itemIndex];

                  return GestureDetector(
                    onTap: () => _onItemTap(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFFC41E3A),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          item.name ?? 'Unnamed Item',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedItemName != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Selected Item: $selectedItemName',
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Quantity: ${quantities[selectedItemName] ?? 1}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      "Total Amount: Rs.${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}
