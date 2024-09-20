import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/billing.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String beepSound = AppAudio.beepSound;

  final AudioPlayer _audioPlayer = AudioPlayer();

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
    // _syncProvider.getItemsAll();
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
      crossAxisCount = 3;
      childAspectRatio = (cardHeight / crossAxisCount) / 310;
      log(screenSize.toString(), name: "800");
    } else {
      crossAxisCount = 3;
      childAspectRatio = (cardHeight / crossAxisCount) / 340;
      log(screenSize.toString(), name: "00");
    }

    return Scaffold(
      appBar: MainAppBar(
        // title: 'Galaxy Mini',
        isRate: true,
        isSearch: true,
        onSearch: (p0) {},
      ),
      body: Column(
        children: [
          Expanded(
            child: Selector<SyncProvider, List<ItemModel>>(
                selector: (p0, p1) => p1.itemList,
                builder: (context, itemList, child) {
                  return itemList.isEmpty
                      ? const Center(
                          child:
                              Text('No Hot Items available. Please sync data.'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: itemList.length,
                          itemBuilder: (context, index) {
                            final item = itemList[index];
                            bool isSelected = selectedItems.contains(item.name);

                            return GestureDetector(
                              onTap: () => _onItemTap(item),
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
                                    color: isSelected
                                        ? AppColors.blue
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                      const SizedBox(height: 8),
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
                        );
                }),
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
