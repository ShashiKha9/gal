import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/arrange_departments.dart';
import 'package:galaxy_mini/screens/arrange_items.dart';
import 'package:galaxy_mini/screens/billing.dart';
import 'package:provider/provider.dart';
import '../components/main_appbar.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  int _selectedDepartmentIndex = 0;
  String? selectedItemName; // Track selected department
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    // Sync data will be triggered from the drawer, so no initial data fetching here
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
          totalAmount: totalAmount,
          parkedOrders: [],
        ),
      ),
    );
  }

    void _showEditDialog() {
    final selectedDepartment = _syncProvider.departmentList[_selectedDepartmentIndex];
    final departmentNameController = TextEditingController(text: selectedDepartment.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Department'),
          content: TextField(
            controller: departmentNameController,
            decoration: const InputDecoration(
              labelText: 'Department Name',
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
                final newName = departmentNameController.text;
                if (newName.isNotEmpty) {
                  setState(() {
                    // Update the department name
                    _syncProvider.departmentList[_selectedDepartmentIndex].description = newName;
                    // Save the updated department list to SharedPreferences or backend if needed
                    _syncProvider.saveDepartmentsOrder(); 
                  });
                }
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
    return Scaffold(
      appBar: MainAppBar(
        title: 'Department',
        onSearch: (String) {},
      ),
      floatingActionButton: widget.isEdit
          ? SpeedDial(
              activeIcon: Icons.close,
              iconTheme: const IconThemeData(color: Colors.red),
              buttonSize: const Size(58, 58),
              curve: Curves.bounceIn,
              children: [
                SpeedDialChild(
                  elevation: 0,
                  labelWidget: const Text(
                    "Edit Department",
                    style: TextStyle(color: Colors.red),
                  ),
                  backgroundColor: Colors.white,
                  onTap: _showEditDialog,
                ),
                SpeedDialChild(
                  elevation: 0,
                  labelWidget: const Text(
                    "Arrange Departments",
                    style: TextStyle(color: Colors.red),
                  ),
                  backgroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArrangeDepartments(),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  elevation: 0,
                  labelWidget: const Text(
                    "Arrange Hot Items",
                    style: TextStyle(color: Colors.red),
                  ),
                  backgroundColor: Colors.white,
                  onTap: () async {
                    // Call the navigate function
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArrangeItems(),
                      ),
                    );

                    // Refresh items if reordering was saved
                    if (result == true) {
                      setState(() {
                        _syncProvider.loadItemsOrder();
                      });
                    }
                  },
                ),
              ],
              child: const Icon(
                Icons.add,
                color: Colors.red,
              ),
            )
          : const SizedBox(),
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
        );
      }),
    );
  }
}
