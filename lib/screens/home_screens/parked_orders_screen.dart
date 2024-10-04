import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/screens/details_screens/parked_order_detail.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class ParkedOrderScreen extends StatefulWidget {
  const ParkedOrderScreen({super.key});

  @override
  _ParkedOrderScreenState createState() => _ParkedOrderScreenState();
}

class _ParkedOrderScreenState extends State<ParkedOrderScreen> {
  String? selectedGroup;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final parkedOrders =
          Provider.of<ParkedOrderProvider>(context, listen: false).parkedOrders;

      log('Parked Orders: $parkedOrders');

      // Automatically select the first group if available
      final uniqueGroups = parkedOrders
          .map((order) => order['tablegroup'] as String?)
          .where((group) => group != null)
          .cast<String>()
          .toSet()
          .toList();

      if (uniqueGroups.isNotEmpty) {
        setState(() {
          selectedGroup = uniqueGroups.first;
        });
      }
    });
  }

  // Show dialog to edit order details
  void _showEditDialog(Map<String, dynamic> order) {
    final orderNameController = TextEditingController(text: order['tableName']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Order Details'),
          content: TextField(
            controller: orderNameController,
            decoration: const InputDecoration(
              labelText: 'Order Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle saving the edited order name here
                // Update your provider state if necessary
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkedOrders = Provider.of<ParkedOrderProvider>(context).parkedOrders;

    final uniqueGroups = parkedOrders
        .map((order) => order['tablegroup'] as String?)
        .where((group) => group != null)
        .cast<String>()
        .toSet()
        .toList();

    final filteredOrders = selectedGroup == null
        ? parkedOrders
        : parkedOrders
            .where((order) => order['tablegroup'] == selectedGroup)
            .toList();

    return Scaffold(
      appBar: MainAppBar(
        isMenu: true,
        title: "Parked Orders",
        onSearch: (p0) {},
      ),
      body: Column(
        children: [
          Consumer<ParkedOrderProvider>(
            builder: (context, parkProvider, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: uniqueGroups.map((group) {
                      final isSelected = selectedGroup == group;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            ChoiceChip(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              label: Text(
                                group,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedGroup = selected ? group : group;
                                });
                              },
                              showCheckmark: false,
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'No parked orders for this group',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Adjust as needed for your layout
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkedOrderDetail(
                                items: List<Map<String, dynamic>>.from(
                                    order['items']),
                                quantities: Map<String, double>.from(
                                    order['quantities']),
                                rates: (order['rates'] as Map?)
                                        ?.cast<String, double>() ??
                                    {},
                                totalAmount: order['totalAmount'] ?? 0.0,
                                tableName: '',
                                tableGroup: '',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: Center(
                            child: Text(
                              order['tableName'] ?? 'Unnamed order',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
