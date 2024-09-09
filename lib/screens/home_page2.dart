import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'billing.dart';
import '../services/dataprovider.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});
  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  bool isLoading = false;
  String? selectedItemName;
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    // _syncProvider.getItemsAll();
  }


  void _onItemTap(Map<String, dynamic> item) {
    setState(() {
      selectedItemName = item['name'];

      if (!quantities.containsKey(item['name'])) {
        quantities[item['name']] = 1;
      } else {
        quantities[item['name']] = quantities[item['name']]! + 1;
      }

      double rate1 = rates[item['name']] ?? 0.0;
      totalAmount += rate1;
    });
  }

  void _increaseQuantity() {
    if (selectedItemName != null) {
      setState(() {
        double rate1 = rates[selectedItemName!] ?? 0.0;
        totalAmount += rate1;
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) + 1;
      });
    }
  }

  void _decreaseQuantity() {
    if (selectedItemName != null &&
        quantities.containsKey(selectedItemName) &&
        quantities[selectedItemName]! > 1) {
      setState(() {
        double rate1 = rates[selectedItemName!] ?? 0.0;
        totalAmount -= rate1;
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) - 1;
      });
    } else if (quantities[selectedItemName] == 1) {
      setState(() {
        double rate1 = rates[selectedItemName!] ?? 0.0;
        totalAmount -= rate1;
        quantities.remove(selectedItemName);
        selectedItemName = quantities.keys.isNotEmpty ? quantities.keys.last : null;
      });
    }
  }

  void _navigateToBillPage() {
    final addedItems = Provider.of<DataProvider>(context, listen: false).items.where((item) => quantities.containsKey(item['name'])).toList();

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
    final items = Provider.of<DataProvider>(context).items;

    return Scaffold(
      appBar: MainAppBar(title: 'Galaxy Mini', onSearch: (p0 ) {  },),
      // drawer: SideDrawer(
      //   apiService: apiService,
      //   onSyncHomePage: _handleSync,
      //   onSyncDepartmentPage: () {}, // Implement department sync if needed
      //   onSyncSuccess: _showSyncSuccessMessage,
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: items.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Selector<SyncProvider, List<ItemModel>>(
                selector: (p0, p1) => p1.itemList,
                builder: (context, items, child) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        // onTap: () => _onItemTap(item),
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
                  );
                }
              ),
            )
                : const Center(child: Text('No items found')),
          ),
          if (selectedItemName != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Selected Item: $selectedItemName',
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quantity: ${quantities[selectedItemName] ?? 1}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "Total Amount: Rs.${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
