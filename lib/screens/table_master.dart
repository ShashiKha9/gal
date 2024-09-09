import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class Tablemaster extends StatefulWidget {
  const Tablemaster({super.key});

  @override
  State<Tablemaster> createState() => _TablemasterState();
}

class _TablemasterState extends State<Tablemaster> {
  late SyncProvider _syncProvider; // List to store table names

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  void _showEditDialog(int index) {
    final selectedTable = _syncProvider.tablemasterList[index];
    final tableNameController = TextEditingController(text: selectedTable.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit table name'),
          content: TextField(
            controller: tableNameController,
            decoration: const InputDecoration(
              labelText: 'Table Name',
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
                final newName = tableNameController.text;
                if (newName.isNotEmpty) {
                  setState(() {
                    // Update the table name
                    _syncProvider.tablemasterList[index].name = newName;
                    // You might want to save the updated list to SharedPreferences or backend
                    // _syncProvider.saveTableNames();
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
        title: 'Table Master',
        onSearch: (String) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(
          Icons.add,
          color: Colors.red,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.tablemasterList.length.toString(),
                  name: 'Consumer length');
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1,
                ),
                itemCount: syncProvider.tablemasterList.length,
                itemBuilder: (context, index) {
                  final table = syncProvider.tablemasterList[index];
                  return GestureDetector(
                    onTap: () => _showEditDialog(index), // Pass the index
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
                          table.name ?? 'Unnamed table',
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
            }),
          ),
        ],
      ),
    );
  }
}
