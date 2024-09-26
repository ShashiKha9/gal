import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/details_screens/item_detail.dart';
import 'package:galaxy_mini/screens/master_settings_screens/item_master_screens/arrange_departments.dart';
import 'package:galaxy_mini/screens/master_settings_screens/item_master_screens/arrange_items.dart';
import 'package:galaxy_mini/screens/billing.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../components/main_appbar.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  _DepartmentScreenState createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  String beepSound = AppAudio.beepSound;

  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedDepartmentIndex = 0;
  String? selectedItemName;
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;
  Set<String> selectedItems = {};

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
      if (selectedItems.contains(item.name)) {
        selectedItems.remove(item.name);
      } else {
        selectedItems.add(item.name!);
      }

      if (!quantities.containsKey(item.name)) {
        quantities[item.name!] = 1;
      } else {
        quantities[item.name!] = quantities[item.name]! + 1;
      }

      double rate1 = double.tryParse(item.rate1 ?? '0.0') ?? 0.0;
      rates[item.name!] = rate1;
      totalAmount += rate1;
    });
  }

  void _onTapNavigate(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetail(
            // item: item,
            itemName: item.name,
            itemShortName: item.shortName,
            itemDepartmentCode: item.departmentCode,
            itemKotGroup: item.kotgroup,
            itemRate1: item.rate1,
            itemRate2: item.rate2,
            itemGST: item.gStcode,
            itemUnit: item.unit,
            itemBarcode: item.barcode,
            itemQRcode: item.qrcode,
            itemHSN: item.hsnCode,
            itemDisplayInSelection: item.displayinselection,
            itemIsHotItem: item.isHot,
            itemQtyInDecimal: item.qtyInDecimal,
            itemIsOpenPrice: item.openPrice,
            itemHasKOTMessage: item.hasKotMessage),
      ),
    );
  }

  void _increaseQuantity() async {
    if (selectedItemName != null) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(beepSound));

      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;
        totalAmount += rate;

        // Increment quantity
        quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) + 1;

        // Ensure the item is in the selectedItems
        if (!selectedItems.contains(selectedItemName)) {
          selectedItems.add(selectedItemName!);
        }
      });
    }
  }

  void _decreaseQuantity() async {
    if (selectedItemName != null && quantities.containsKey(selectedItemName)) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(beepSound));

      setState(() {
        double rate = rates[selectedItemName!] ?? 0.0;

        // If the quantity is greater than 1, decrease it
        if (quantities[selectedItemName]! > 1) {
          totalAmount -= rate;
          quantities[selectedItemName!] = quantities[selectedItemName]! - 1;

          // If the quantity is 1, remove the item from quantities and selectedItems
        } else if (quantities[selectedItemName] == 1) {
          totalAmount -= rate;
          quantities.remove(selectedItemName);
          selectedItems.remove(selectedItemName);

          // Update selectedItemName to another item if available
          selectedItemName =
              quantities.isNotEmpty ? quantities.keys.last : null;
        }
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

  SpeedDialChild commonSpeedDialChild({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      elevation: 4,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      labelWidget: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.blue,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
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
      crossAxisCount = 10;
      childAspectRatio = (cardHeight / crossAxisCount) / 95;
      log(screenSize.toString(), name: "1200");
    } else if (screenSize.width > 1000) {
      crossAxisCount = 8;
      childAspectRatio = (cardHeight / crossAxisCount) / 95;
      log(screenSize.toString(), name: "1000");
    } else if (screenSize.width > 800 || screenSize.width >= 800) {
      crossAxisCount = 4;
      childAspectRatio = (cardHeight / crossAxisCount) / 250;
      log(screenSize.toString(), name: "800");
    } else {
      crossAxisCount = 3;
      childAspectRatio = (cardHeight / crossAxisCount) / 340;
      log(screenSize.toString(), name: "00");
    }

    return Scaffold(
      appBar: MainAppBar(
        isSearch: true,
        onSearch: (p0) {},
        isMenu: widget.isEdit ? false : true,
        actions: true,
        actionWidget: InkWell(
          onTap: () {},
          child: Row(
            children: [
              const Text(
                "Rate 1",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Transform.rotate(
                angle: 90 * math.pi / 180,
                child: const Icon(
                  Icons.compare_arrows,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.isEdit
          ? SpeedDial(
              activeIcon: Icons.close,
              buttonSize: const Size(58, 58),
              curve: Curves.bounceIn,
              children: [
                commonSpeedDialChild(
                  label: "Edit  Department",
                  icon: Icons.edit,
                  onTap: _showEditDialog,
                ),
                commonSpeedDialChild(
                  label: "Arrange Departments",
                  icon: Icons.list,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArrangeDepartments(),
                      ),
                    );
                  },
                ),
                commonSpeedDialChild(
                  label: "Arrange Hot Items",
                  icon: Icons.list_alt,
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArrangeItems(),
                      ),
                    );

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
                    child: Material(
                      child: ChoiceChip(
                        label: Text(
                          department.description,
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
                        avatar: null,
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
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
                  bool isSelected = selectedItems.contains(item.name) ||
                      (quantities[item.name] ?? 0) > 0;

                  return GestureDetector(
                    onTap: () =>
                        widget.isEdit ? _onTapNavigate(item) : _onItemTap(item),
                    child: Card(
                      color: Colors.white,
                      // surfaceTintColor: AppColors.lightPink,
                      borderOnForeground: true,
                      elevation: 2,
                      semanticContainer: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        side: BorderSide(
                          color:
                              isSelected ? AppColors.blue : Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              // padding: const EdgeInsets.all(10),
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
                                  ? const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.wallpaper,
                                        color: AppColors.lightGrey,
                                        size: 50,
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                  sigmaX: 10, sigmaY: 10),
                                              child: Image.network(
                                                item.imageUrl ?? "",
                                                height: 70,
                                                width: double.maxFinite,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              item.imageUrl ?? "",
                                              height: 70,
                                              width: double.maxFinite,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
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
                                    color: AppColors.lessBlue,
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
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              // border: Border.all(
                                              //   color: Colors.black,
                                              // ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(50),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: _decreaseQuantity,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.blue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.remove,
                                                      color: Colors.white,
                                                    ),
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
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.blue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
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
                                    color: AppColors.blue,
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
                                            color: Colors.white,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Text(
                                          "₹ $totalAmount",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
