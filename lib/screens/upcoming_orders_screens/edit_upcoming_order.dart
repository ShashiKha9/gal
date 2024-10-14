import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/screens/upcoming_orders_screens/add_new_upcoming_item.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class EditUpcomingOrder extends StatefulWidget {
  final String orderId;

  const EditUpcomingOrder({
    super.key,
    required this.orderId,
  });

  @override
  EditUpcomingOrderState createState() => EditUpcomingOrderState();
}

class EditUpcomingOrderState extends State<EditUpcomingOrder> {
  Map<String, dynamic>? order;
  late SyncProvider syncProvider;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
    syncProvider.getTaxAll();
  }

  double _calculateTotalWithTax(double subTotal) {
    // Fetch tax values, ensuring to handle potential nulls or empty values
    double cgst = double.tryParse(syncProvider.taxList.first.cGst) ??
        0.0; // Replace with actual field names from your provider
    double sgst = double.tryParse(syncProvider.taxList.first.sgst) ?? 0.0;
    double igst = double.tryParse(syncProvider.taxList.first.iGst) ?? 0.0;

    // Calculate total tax
    double totalTax = (cgst + sgst + igst);

    // Return the total amount including tax
    return subTotal + subTotal * (totalTax / 100);
  }

  void _loadOrderData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<UpcomingOrderProvider>(context, listen: false);
      provider.loadOrders().then((_) {
        setState(() {
          order = provider.upcomingOrders.firstWhere(
              (order) => order['orderId'] == widget.orderId,
              orElse: () => {});
        });
      });
    });
  }

  void _increaseQuantity(String itemName) {
    setState(() {
      order!['quantities'][itemName] += 1;
      _updateTotals(itemName);
    });
  }

  void _decreaseQuantity(String itemName) {
    setState(() {
      if (order!['quantities'][itemName] > 1) {
        order!['quantities'][itemName] -= 1;
      } else {
        order!['items'].removeWhere((item) => item['name'] == itemName);
        order!['quantities'].remove(itemName);
        order!['rates'].remove(itemName);
      }
      _updateTotals(itemName);
    });
  }

  void _updateTotals(String itemName) {
    double totalAmount = 0.0;
    for (var item in order!['items']) {
      String currentItemName = item['name'];
      totalAmount += order!['quantities'][currentItemName] *
          order!['rates'][currentItemName];
    }

    setState(() {
      order!['totalAmount'] = totalAmount;
      order!['remainingAmount'] =
          order!['totalAmount'] - order!['advanceAmount'];
    });
  }

  void _saveChanges() async {
    final provider = Provider.of<UpcomingOrderProvider>(context, listen: false);
    await provider.updateOrderInSharedPreferences(widget.orderId);
    Fluttertoast.showToast(
      msg: "Order Saved Successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (order == null || order!.isEmpty) {
      return const Scaffold(
        appBar: MainAppBar(
          title: 'Order Details',
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: const MainAppBar(
        title: 'Edit Order',
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Code: ${order!['customerCode']}'),
                          Text('Customer Name: ${order!['customerName']}'),
                          Text(
                            'Order ID: ${order!['orderId']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Order Date: ${order!['orderDate']} ${order!['orderTime']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Order Placed on: ${order!['orderPlacedTime']}'),
                          Text('Note: ${order!['note']}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Item Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order!['items'].length,
                    itemBuilder: (context, itemIndex) {
                      String itemName = order!['items'][itemIndex]['name'];
                      double quantity = order!['quantities'][itemName];
                      double rate = order!['rates'][itemName];
                      double price = quantity * rate;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(8.0).copyWith(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _decreaseQuantity(itemName),
                                          icon: const Icon(Icons.remove_circle),
                                          color: Colors.red,
                                          iconSize: 24,
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: Center(
                                            child: Text(
                                              quantity.toString(),
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _increaseQuantity(itemName),
                                          icon: const Icon(Icons.add_circle),
                                          color: Colors.green,
                                          iconSize: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Price: ₹ ${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        buttonText: "Add More Items",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNewUpcomingItem(
                                  orderId: order!['orderId']),
                            ),
                          ).then((_) {
                            // This will refresh the EditUpcomingOrder screen when the user returns from the AddNewUpcomingItem screen
                            _loadOrderData();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub Total: ₹ ${order!['totalAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'CGST: ${syncProvider.taxList.first.cGst}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Display SGST
                          Text(
                            'SGST: ${syncProvider.taxList.first.sgst}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Display IGST
                          Text(
                            'IGST: ${syncProvider.taxList.first.iGst}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Total Amount: ₹ ${_calculateTotalWithTax(order!['totalAmount'])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                          Text(
                            'Advance Amount: ₹ ${order!['advanceAmount']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Balance Amount: ₹ ${(_calculateTotalWithTax(order?['totalAmount'] ?? 0)) - (order?['advanceAmount'] ?? 0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppButton(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(0),
                        buttonText: "Save",
                        onTap: () => _saveChanges(),
                      ),
                      AppButton(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(0),
                        buttonText: "Cancel",
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
