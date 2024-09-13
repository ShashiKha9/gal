import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/arrange_departments.dart';
import 'package:galaxy_mini/screens/arrange_items.dart';
import 'package:galaxy_mini/screens/billing.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../components/main_appbar.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  String beepSound = AppAudio.beepSound;

  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedDepartmentIndex = 0;
  String? selectedItemName;
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onItemTap(ItemModel item) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(beepSound));

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

  void _increaseQuantity() async {
    if (selectedItemName != null) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(beepSound));

      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount += rate;
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) + 1;
      });
    }
  }

  void _decreaseQuantity() async {
    if (selectedItemName != null &&
        quantities.containsKey(selectedItemName) &&
        quantities[selectedItemName]! > 1) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(beepSound));
      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount -= rate;
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) - 1;
      });
    } else if (quantities[selectedItemName] == 1) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(beepSound));
      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount -= rate;
        quantities.remove(selectedItemName);
        selectedItemName = quantities.isNotEmpty ? quantities.keys.last : null;
      });
    }
  }

  void _navigateToBillPage() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(beepSound));

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
          parkedOrders: const [],
        ),
      ),
    );
  }

  void _showEditDialog() {
    final selectedDepartment =
        _syncProvider.departmentList[_selectedDepartmentIndex];
    final departmentNameController =
        TextEditingController(text: selectedDepartment.description);

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
                    _syncProvider.departmentList[_selectedDepartmentIndex]
                        .description = newName;
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
    final screenSize = MediaQuery.of(context).size;
    double cardHeight = MediaQuery.of(context).size.height;
    int crossAxisCount;
    double childAspectRatio;
    log(screenSize.toString(), name: "screenSize");

    if (screenSize.width > 1200) {
      crossAxisCount = 8;
      childAspectRatio = (cardHeight / crossAxisCount) / 300;
      log(screenSize.toString(), name: "1200");
    }
    if (screenSize.width > 1000) {
      crossAxisCount = 6;
      childAspectRatio = (cardHeight / crossAxisCount) / 105;
      log(screenSize.toString(), name: "1000");
    } else if (screenSize.width > 800) {
      crossAxisCount = 4;
      childAspectRatio = (cardHeight / crossAxisCount) / 310;
      log(screenSize.toString(), name: "800");
    } else {
      crossAxisCount = 3;
      childAspectRatio = (cardHeight / crossAxisCount) / 340;
      log(screenSize.toString(), name: "00");
    }

    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: MainAppBar(
        // title: 'Department',
        isSearch: true,
        isRate: true,
        onSearch: (p0) {},
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
                        builder: (context) => const ArrangeDepartments(),
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
        if (syncProvider.departmentList.isEmpty) {
          return const Center(
            child: Text('No departments available. Please sync data.'),
          );
        }
        return Column(
          children: [
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDepartmentIndex = index;
                        });
                      },
                      // selectedColor: AppColors.white,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: childAspectRatio,
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
                    child: Card(
                      color: Colors.white,
                      // surfaceTintColor: AppColors.lightPink,
                      borderOnForeground: true,
                      elevation: 2,
                      semanticContainer: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              width: double.maxFinite,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                // border: Border(
                                //   bottom: BorderSide(
                                //     color: AppColors.lightPink,
                                //     width: 2,
                                //   ),
                                // ),
                              ),
                              child: item.imageUrl == null ||
                                      item.imageUrl!.isEmpty
                                  ? const Icon(
                                      Icons.wallpaper,
                                      color: AppColors.lightGrey,
                                      size: 50,
                                    )
                                  : Image.network(item.imageUrl ?? ""),
                            ),

                            SizedBox(
                              // height: 30,
                              child: Text(
                                item.name ?? "NO Name",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            // const SizedBox(height: 8),
                            Text(
                              "₹ ${item.rate1}",
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            // Text(
                            //   "Rate 2: ₹ ${item.rate2}",
                            //   style: const TextStyle(
                            //     fontSize: 10.5,
                            //     fontWeight: FontWeight.bold,
                            //     color: AppColors.blue,
                            //   ),
                            // ),
                            // const SizedBox(height: 5),
                            // SizedBox(
                            //   height: 25,
                            //   child: AppButton(
                            //     onTap: () => _onItemTap(item),
                            //     buttonText: "Add",
                            //     margin: EdgeInsets.zero,
                            //     padding: EdgeInsets.zero,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedItemName != null)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
                                child: Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 15,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "$selectedItemName",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "₹ $totalAmount",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 100,
                                            maxWidth: 112,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: _decreaseQuantity,
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Text(
                                                  "${quantities[selectedItemName]}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                InkWell(
                                                  onTap: _increaseQuantity,
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "TOTAL:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Text(
                                          "₹ $totalAmount",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () => _navigateToBillPage(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
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
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 50,
                                ),
                                child: Icon(
                                  Icons.print,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}
