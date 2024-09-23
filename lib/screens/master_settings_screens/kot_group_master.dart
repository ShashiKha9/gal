import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class KotGroupMaster extends StatefulWidget {
  const KotGroupMaster({super.key});

  @override
  State<KotGroupMaster> createState() => _KotGroupMasterState();
}

class _KotGroupMasterState extends State<KotGroupMaster> {
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  void _showEditDialog(int index) {
    final selectedKotGroup = _syncProvider.kotgroupList[index];
    final nameController = TextEditingController(text: selectedKotGroup.name);
    final descriptionController =
        TextEditingController(text: selectedKotGroup.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit KOT Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'KOT Group Name',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'KOT Group Description',
                ),
              ),
            ],
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
                final newName = nameController.text;
                final newDescription = descriptionController.text;
                if (newName.isNotEmpty || newDescription.isNotEmpty) {
                  setState(() {
                    _syncProvider.updateKotGroup(
                      selectedKotGroup.code, // Assuming you have a unique code
                      newName.isNotEmpty ? newName : selectedKotGroup.name,
                      newDescription.isNotEmpty
                          ? newDescription
                          : selectedKotGroup.description,
                    );
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
        title: 'KOT Group Master',
        isMenu: false,
        onSearch: (value) {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SyncProvider>(
          builder: (context, syncProvider, child) {
            log(syncProvider.kotgroupList.length.toString(),
                name: 'KOT Group List Length');
            return ListView.builder(
              itemCount: syncProvider.kotgroupList.length,
              itemBuilder: (context, index) {
                final kotgroup = syncProvider.kotgroupList[index];
                return GestureDetector(
                  onTap: () =>
                      _showEditDialog(index), // Show edit dialog on tap
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${kotgroup.name}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description: ${kotgroup.description ?? 'No description'}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
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
    );
  }
}
