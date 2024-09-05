import 'dart:developer';
import 'package:flutter/material.dart';
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
    _syncProvider.getItemsAll().then((_){
      _syncProvider.loadItemsOrder();
    });
  }

    void _saveOrder() {
    _syncProvider.saveItemsOrder(); // Save order to SharedPreferences
    Navigator.of(context).pop(); // Navigate back or close the screen
  }

  void _cancelChanges() {
    _syncProvider.loadItemsOrder(); // Reload the saved order to discard changes
    Navigator.of(context).pop(); // Navigate back or close the screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arrange Hot Items')),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.itemList.length.toString(),
                  name: 'Consumer length');
              return ReorderableGridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1,
                ),
                itemCount: syncProvider.itemList.length,
                itemBuilder: (context, index) {
                  final item = syncProvider.itemList[index];
                  return Container(
                    key: ValueKey(item.name),
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
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _cancelChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Set cancel button color
                  ),
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
