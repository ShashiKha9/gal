import 'dart:developer';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/billing.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class HotItemsScreen extends StatefulWidget {
  const HotItemsScreen({super.key});

  @override
  State<HotItemsScreen> createState() => _HotItemsScreenState();
}

class _HotItemsScreenState extends State<HotItemsScreen> {
  String beepSound = AppAudio.beepSound;

  final AudioPlayer _audioPlayer = AudioPlayer();

  String? selectedItemName;
  double totalAmount = 0.0;
  Map<String, double> quantities = {};
  Map<String, double> rates = {};
  late SyncProvider _syncProvider;
  Set<String> selectedItems = {};
  bool isRate1 = true;
  List<ItemModel> filteredItemList = [];

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    // _syncProvider.getItemsAll();
    _syncProvider.loadItemListFromPrefs().then((value) {
      filteredItemList = _syncProvider.itemList;
    });
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

      double rate = isRate1
          ? double.tryParse(item.rate1 ?? '0.0') ?? 0.0
          : double.tryParse(item.rate2 ?? '0.0') ?? 0.0;

      rates[item.name!] = rate;
      totalAmount += rate;
    });
  }

  // New search function
  void _filterItems(String? query) {
    if (query == null || query.isEmpty) {
      // If the search query is empty, show all items
      setState(() {
        filteredItemList = _syncProvider.itemList;
      });
    } else {
      // Filter the items based on the query
      setState(() {
        filteredItemList = _syncProvider.itemList.where((item) {
          return item.name!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
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
              'rate': isRate1 ? item.rate1 : item.rate2,
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
      childAspectRatio = (cardHeight / crossAxisCount) / 350;
      log(screenSize.toString(), name: "00");
    }

    return Scaffold(
      appBar: MainAppBar(
        // title: 'Galaxy Mini',
        isMenu: true,
        isSearch: true,
        onSearch: _filterItems,
        actions: true,
        actionWidget: GestureDetector(
          onTap: () {
            setState(() {
              // Toggle the rate between rate1 and rate2
              isRate1 = !isRate1;
              log("Rate changed to: ${isRate1 ? 'Rate 1' : 'Rate 2'}");
            });
          },
          child: Row(
            children: [
              Text(
                isRate1 ? 'Rate 1' : 'Rate 2',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
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
      body: Column(
        children: [
          Expanded(
            child: Selector<SyncProvider, List<ItemModel>>(
              selector: (p0, p1) => filteredItemList,
              builder: (context, itemList, child) {
                return itemList.isEmpty
                    ? const Center(
                        child:
                            Text('No Hot Items available. Please sync data.'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          final item = itemList[index];
                          bool isSelected = selectedItems.contains(item.name) ||
                              (quantities[item.name] ?? 0) > 0;

                          return GestureDetector(
                            onTap: () => _onItemTap(item),
                            child: Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors
                                          .blue // Show blue border if selected
                                      : Colors
                                          .transparent, // No border if not selected
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: double.maxFinite,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
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
                                                        BorderRadius.circular(
                                                            10),
                                                    child: ImageFiltered(
                                                      imageFilter:
                                                          ImageFilter.blur(
                                                              sigmaX: 10,
                                                              sigmaY: 10),
                                                      child: Image.network(
                                                        item.imageUrl!,
                                                        height: 70,
                                                        width: double.maxFinite,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          // Show icon if the image fails to load
                                                          return const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Icon(
                                                              Icons.wallpaper,
                                                              color: AppColors
                                                                  .lightGrey,
                                                              size: 50,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      item.imageUrl!,
                                                      height: 70,
                                                      width: double.maxFinite,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Icon(
                                                            Icons.wallpaper,
                                                            color: AppColors
                                                                .lightGrey,
                                                            size: 50,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                    ),
                                    SizedBox(
                                      child: Text(
                                        item.name ?? "NO Name",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "₹ ${isRate1 ? item.rate1 : item.rate2}",
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                                MainAxisAlignment.spaceBetween,
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
      ),
    );
  }
}
