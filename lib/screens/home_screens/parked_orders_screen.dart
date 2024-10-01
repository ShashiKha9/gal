import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/screens/details_screens/parked_order_detail.dart';

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
    // Since parked orders are now loaded via SyncData, remove loadParkedOrders from here
    // Instead, log or handle the loaded parked orders as needed
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: uniqueGroups.map((group) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(group),
                    selected: selectedGroup == group,
                    onSelected: (selected) {
                      setState(() {
                        selectedGroup = selected ? group : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'No parked orders for this group',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 1, 
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
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
                                        ?.cast<String, double>() ?? {},
                                totalAmount: order['totalAmount'] ?? 0.0, tableName: '', tableGroup: '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Table: ${order['tableName']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
