import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/billing.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String? selectedItemName;
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    // _syncProvider.getItemsAll();
  }

  void _onItemTap(ItemModel item) {
    setState(() {
      selectedItemName = item.name;

      if (!quantities.containsKey(item.name)) {
        quantities[item.name!] = 1;
      } else {
        quantities[item.name!] = quantities[item.name]! + 1;
      }

      double rate1 = double.tryParse(item.rate1 ?? '0.0') ?? 0.0;
      rates[item.name!] = rate1; // Store the rate
      totalAmount += rate1;
    });
  }

  void _increaseQuantity() {
    if (selectedItemName != null) {
      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount += rate;
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) + 1;
      });
    }
  }

  void _decreaseQuantity() {
    if (selectedItemName != null &&
        quantities.containsKey(selectedItemName) &&
        quantities[selectedItemName]! > 1) {
      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount -= rate;
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) - 1;
      });
    } else if (quantities[selectedItemName] == 1) {
      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount -= rate;
        quantities.remove(selectedItemName);
        selectedItemName = quantities.isNotEmpty ? quantities.keys.last : null;
      });
    }
  }

  void _navigateToBillPage() {
    final addedItems = _syncProvider.itemList
        .where((item) => quantities.containsKey(item.name))
        .map((item) => {
              'name': item.name,
              'rate1': item.rate1,
              // add other fields as needed
            })
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillPage(
          items: addedItems,
          quantities: quantities,
          rates: rates,
          // ignore: prefer_const_literals_to_create_immutables
          totalAmount: totalAmount, parkedOrders: [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncProvider.loadItemsOrder();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(
        title: 'Galaxy Mini',
        onSearch: (p0) {},
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.itemList.length.toString(),
                  name: 'Consumer length');
              return Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: syncProvider.itemList.length,
                  itemBuilder: (context, index) {
                    final item = syncProvider.itemList[index];
                    return GestureDetector(
                      onTap: () => _onItemTap(item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.greenTwo,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 2,
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
              );
            }),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decreaseQuantity,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _increaseQuantity,
                      ),
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: _navigateToBillPage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
