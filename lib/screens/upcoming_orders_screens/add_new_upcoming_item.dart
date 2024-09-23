import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart'; // Import the provider
import 'package:galaxy_mini/provider/upcomingorder_provider.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AddNewUpcomingItem extends StatefulWidget {
  const AddNewUpcomingItem({
    super.key,
    this.isEdit = false,
    required this.orderId,
  });
  final String orderId;
  final bool isEdit;

  @override
  _AddNewUpcomingItemState createState() => _AddNewUpcomingItemState();
}

class _AddNewUpcomingItemState extends State<AddNewUpcomingItem> {
  String beepSound = AppAudio.beepSound;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _selectedDepartmentIndex = 0;
  String? selectedItemName;
  String? itemName;
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;
  late UpcomingOrderProvider _upcomingOrderProvider;
  Set<String> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _upcomingOrderProvider = Provider.of<UpcomingOrderProvider>(context,
        listen: false); // Initialize provider
    _syncProvider.getDepartmentsAll();
  }

  // void _increaseQuantity() async {
  //   if (selectedItemName != null) {
  //     await _audioPlayer.stop();
  //     await _audioPlayer.play(AssetSource(beepSound));

  //     setState(() {
  //       double rate = rates[selectedItemName!] ?? 0.0;
  //       totalAmount += rate;

  //       // Increment quantity
  //       quantities[selectedItemName!] = (quantities[selectedItemName] ?? 1) + 1;

  //       // Ensure the item is in the selectedItems
  //       if (!selectedItems.contains(selectedItemName)) {
  //         selectedItems.add(selectedItemName!);
  //       }
  //     });
  //   }
  // }

  // void _decreaseQuantity() async {
  //   if (selectedItemName != null && quantities.containsKey(selectedItemName)) {
  //     await _audioPlayer.stop();
  //     await _audioPlayer.play(AssetSource(beepSound));

  //     setState(() {
  //       double rate = rates[selectedItemName!] ?? 0.0;

  //       // If the quantity is greater than 1, decrease it
  //       if (quantities[selectedItemName]! > 1) {
  //         totalAmount -= rate;
  //         quantities[selectedItemName!] = quantities[selectedItemName]! - 1;

  //         // If the quantity is 1, remove the item from quantities and selectedItems
  //       } else if (quantities[selectedItemName] == 1) {
  //         totalAmount -= rate;
  //         quantities.remove(selectedItemName);
  //         selectedItems.remove(selectedItemName);

  //         // Update selectedItemName to another item if available
  //         selectedItemName =
  //             quantities.isNotEmpty ? quantities.keys.last : null;
  //       }
  //     });
  //   }
  // }

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
      rates[item.name!] = rate1;

      double itemTotalAmount = quantities[item.name!]! * rate1;

      _upcomingOrderProvider
          .storeItemDetails(
        item.name!,
        quantities[item.name!]!.toDouble(),
        itemTotalAmount,
        widget.orderId,
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
      appBar: const MainAppBar(
        title: 'Department',
        isMenu: false,
        isSearch: true,
      ),
      body: Consumer<SyncProvider>(builder: (context, syncProvider, child) {
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
                    child: Material(
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
            const SizedBox(height: 16),
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
                  // bool isSelected = selectedItems.contains(item.name) ||
                  //     (quantities[item.name] ?? 0) > 0;

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
                        side: BorderSide(
                          color: Colors.transparent,
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
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item.imageUrl ?? "",
                                        height: 70,
                                        width: double.maxFinite,
                                        fit: BoxFit.cover,
                                      ),
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
            // if (selectedItemName != null)
            //   Column(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(8),
            //         child: Row(
            //           children: [
            //             Flexible(
            //               flex: 5,
            //               child: Column(
            //                 children: [
            //                   Padding(
            //                     padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
            //                     child: Container(
            //                       width: double.maxFinite,
            //                       decoration: BoxDecoration(
            //                         color: AppColors.lessBlue,
            //                         borderRadius: const BorderRadius.all(
            //                           Radius.circular(8),
            //                         ),
            //                         boxShadow: [
            //                           BoxShadow(
            //                             color: Colors.grey.withOpacity(0.3),
            //                             spreadRadius: 2,
            //                             blurRadius: 5,
            //                             offset: const Offset(0, 3),
            //                           ),
            //                         ],
            //                       ),
            //                       child: Padding(
            //                         padding: const EdgeInsets.symmetric(
            //                           vertical: 10,
            //                           horizontal: 15,
            //                         ),
            //                         child: Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.end,
            //                           children: [
            //                             Row(
            //                               mainAxisAlignment:
            //                                   MainAxisAlignment.spaceBetween,
            //                               children: [
            //                                 Text(
            //                                   "$selectedItemName",
            //                                   style: const TextStyle(
            //                                     fontWeight: FontWeight.bold,
            //                                     color: Colors.black,
            //                                   ),
            //                                 ),
            //                                 Text(
            //                                   "₹ $totalAmount",
            //                                   style: const TextStyle(
            //                                     fontWeight: FontWeight.bold,
            //                                     color: Colors.black,
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                             const SizedBox(height: 10),
            //                             ConstrainedBox(
            //                               constraints: const BoxConstraints(
            //                                 minWidth: 100,
            //                                 maxWidth: 112,
            //                               ),
            //                               child: Container(
            //                                 decoration: const BoxDecoration(
            //                                   color: Colors.white,
            //                                   // border: Border.all(
            //                                   //   color: Colors.black,
            //                                   // ),
            //                                   borderRadius: BorderRadius.all(
            //                                     Radius.circular(50),
            //                                   ),
            //                                 ),
            //                                 child: Row(
            //                                   mainAxisAlignment:
            //                                       MainAxisAlignment
            //                                           .spaceBetween,
            //                                   children: [
            //                                     InkWell(
            //                                       onTap: _decreaseQuantity,
            //                                       child: Container(
            //                                         decoration:
            //                                             const BoxDecoration(
            //                                           color: AppColors.blue,
            //                                           shape: BoxShape.circle,
            //                                         ),
            //                                         child: const Icon(
            //                                           Icons.remove,
            //                                           color: Colors.white,
            //                                         ),
            //                                       ),
            //                                     ),
            //                                     const SizedBox(width: 15),
            //                                     Text(
            //                                       "${quantities[selectedItemName]}",
            //                                       style: const TextStyle(
            //                                         fontWeight: FontWeight.bold,
            //                                         color: Colors.black,
            //                                       ),
            //                                     ),
            //                                     const SizedBox(width: 15),
            //                                     InkWell(
            //                                       onTap: _increaseQuantity,
            //                                       child: Container(
            //                                         decoration:
            //                                             const BoxDecoration(
            //                                           color: AppColors.blue,
            //                                           shape: BoxShape.circle,
            //                                         ),
            //                                         child: const Icon(
            //                                           Icons.add,
            //                                           color: Colors.white,
            //                                         ),
            //                                       ),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   Padding(
            //                     padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            //                     child: Container(
            //                       width: double.maxFinite,
            //                       decoration: BoxDecoration(
            //                         color: AppColors.blue,
            //                         borderRadius: const BorderRadius.all(
            //                           Radius.circular(8),
            //                         ),
            //                         boxShadow: [
            //                           BoxShadow(
            //                             color: Colors.grey.withOpacity(0.3),
            //                             spreadRadius: 2,
            //                             blurRadius: 5,
            //                             offset: const Offset(0, 3),
            //                           ),
            //                         ],
            //                       ),
            //                       child: Padding(
            //                         padding: const EdgeInsets.symmetric(
            //                           vertical: 10,
            //                           horizontal: 15,
            //                         ),
            //                         child: Row(
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.spaceBetween,
            //                           children: [
            //                             const Text(
            //                               "TOTAL:",
            //                               style: TextStyle(
            //                                 fontWeight: FontWeight.bold,
            //                                 color: Colors.white,
            //                                 fontSize: 17,
            //                               ),
            //                             ),
            //                             Text(
            //                               "₹ $totalAmount",
            //                               style: const TextStyle(
            //                                 fontWeight: FontWeight.bold,
            //                                 color: Colors.white,
            //                                 fontSize: 17,
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             Expanded(
            //               flex: 1,
            //               child: InkWell(
            //                 // onTap: () => _navigateToBillPage(),
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     color: AppColors.red,
            //                     borderRadius: const BorderRadius.all(
            //                       Radius.circular(8),
            //                     ),
            //                     boxShadow: [
            //                       BoxShadow(
            //                         color: Colors.grey.withOpacity(0.3),
            //                         spreadRadius: 2,
            //                         blurRadius: 5,
            //                         offset: const Offset(0, 3),
            //                       ),
            //                     ],
            //                   ),
            //                   child: const Padding(
            //                     padding: EdgeInsets.symmetric(
            //                       vertical: 50,
            //                     ),
            //                     child: Center(
            //                       child: Text(
            //                         "Add",
            //                         style: TextStyle(
            //                           color: Colors.white,
            //                           fontSize: 18,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
          ],
        );
      }),
    );
  }
}
