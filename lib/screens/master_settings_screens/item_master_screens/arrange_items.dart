import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';

class ArrangeItems extends StatefulWidget {
  const ArrangeItems({super.key});

  @override
  State<ArrangeItems> createState() => _ArrangeItemsState();
}

class _ArrangeItemsState extends State<ArrangeItems> {
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _syncProvider.getItemsAll().then((_) {
      _syncProvider.loadItemsOrder();
    });
  }

  void _saveOrder() {
    _syncProvider.saveItemsOrder();
    Navigator.of(context).pop(true);
  }

  void _cancelChanges() {
    _syncProvider.loadItemsOrder();
    Navigator.of(context).pop();
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
      appBar: const MainAppBar(
        title: 'Arrange Hot Items',
        isMenu: false,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.itemList.length.toString(),
                  name: 'Consumer length');
              return ReorderableGridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: syncProvider.itemList.length,
                itemBuilder: (context, index) {
                  final item = syncProvider.itemList[index];
                  return Card(
                    key: ValueKey(item.name),

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
                            child:
                                item.imageUrl == null || item.imageUrl!.isEmpty
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
                          const SizedBox(height: 8),
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
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    // Handle reordering items
                    final item = syncProvider.itemList.removeAt(oldIndex);
                    syncProvider.itemList.insert(newIndex, item);

                    // Notify SyncProvider of the new order
                    // _syncProvider.itemList = List.from(syncProvider.itemList);
                    _syncProvider.saveItemsOrder();
                  });
                },
              );
            }),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _cancelChanges,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveOrder,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
