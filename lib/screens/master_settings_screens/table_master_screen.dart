import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class TablemasterScreen extends StatefulWidget {
  const TablemasterScreen({super.key});

  @override
  State<TablemasterScreen> createState() => _TablemasterScreenState();
}

class _TablemasterScreenState extends State<TablemasterScreen> {
  late SyncProvider _syncProvider;
  String? _selectedGroupCode;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _fetchData();
  }

  // Fetch data and organize tables by group
  Future<void> _fetchData() async {
    await _syncProvider.fetchAndOrganizeTables();
    setState(() {
      // Set the first group selected by default
      if (_syncProvider.tablesByGroup.isNotEmpty) {
        _selectedGroupCode = _syncProvider.tablesByGroup.keys.first;
      }
    });
  }

  // Show dialog to edit table name
  void _showEditDialog(int index, String groupCode) {
    final selectedTable = _syncProvider.tablesByGroup[groupCode]?[index];
    final tableNameController =
        TextEditingController(text: selectedTable?.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Table Name'),
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
                    selectedTable?.name = newName;
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

  // Show dialog to edit group name
  void _showEditGroupDialog() {
    if (_selectedGroupCode == null) return;

    final selectedGroup = _syncProvider.tablegroupList.firstWhere(
      (group) => group.code == _selectedGroupCode,
    );

    final groupNameController = TextEditingController(
      text: selectedGroup.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Group Name'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
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
                final newName = groupNameController.text;
                if (newName.isNotEmpty && _selectedGroupCode != null) {
                  // Update the group name in the provider
                  _syncProvider.updateTableGroup(
                      _selectedGroupCode!, newName, '');

                  // No need to re-fetch data manually
                  // _fetchData(); -> this is not necessary

                  setState(
                      () {}); // Optionally call setState to ensure local UI update

                  Navigator.pop(context);
                }
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
      crossAxisCount = 10;
      childAspectRatio = (cardHeight / crossAxisCount) / 95;
      log(screenSize.toString(), name: "1200");
    } else if (screenSize.width > 1000) {
      crossAxisCount = 8;
      childAspectRatio = (cardHeight / crossAxisCount) / 95;
      log(screenSize.toString(), name: "1000");
    } else if (screenSize.width > 800 || screenSize.width >= 800) {
      crossAxisCount = 6;
      childAspectRatio = (cardHeight / crossAxisCount) / 60;
      log(screenSize.toString(), name: "800");
    } else {
      crossAxisCount = 3;
      childAspectRatio = (cardHeight / crossAxisCount) / 250;
      log(screenSize.toString(), name: "00");
    }

    return Scaffold(
      appBar: MainAppBar(
        title: 'Table Master',
        onSearch: (p0) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditGroupDialog,
        child: const Icon(Icons.edit),
      ),
      body: Column(
        children: [
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: syncProvider.tablesByGroup.keys.map((groupCode) {
                      final isSelected = _selectedGroupCode == groupCode;
                      final groupName = syncProvider.tablegroupList
                          .firstWhere((group) => group.code == groupCode)
                          .name;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            ChoiceChip(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              label: Text(
                                groupName,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedGroupCode = groupCode;
                                  }
                                });
                              },
                              showCheckmark: false,
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<SyncProvider>(
              builder: (context, syncProvider, child) {
                // Get tables of the selected group or all if none selected
                final groupTables = _selectedGroupCode != null
                    ? syncProvider.tablesByGroup[_selectedGroupCode] ?? []
                    : [];

                if (groupTables.isEmpty) {
                  return const Center(
                      child: Text('No tables available for this group.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: groupTables.length,
                  itemBuilder: (context, index) {
                    final table = groupTables[index];
                    return GestureDetector(
                      onTap: () => _showEditDialog(index, _selectedGroupCode!),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: Center(
                          child: Text(
                            table.name ?? 'Unnamed table',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
