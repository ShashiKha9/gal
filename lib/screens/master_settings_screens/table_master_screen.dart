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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Table Master',
        isMenu: false,
        onSearch: (p0) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new table
        },
        child: const Icon(
          Icons.add,
          color: Colors.red,
        ),
      ),
      body: Column(
        children: [
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: syncProvider.tablesByGroup.keys.map((groupCode) {
                    final isSelected = _selectedGroupCode == groupCode;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Material(
                        child: ChoiceChip(
                          label: Text(
                            'Group $groupCode',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGroupCode = selected ? groupCode : null;
                            });
                          },
                          showCheckmark: false,
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: groupTables.length,
                  itemBuilder: (context, index) {
                    final table = groupTables[index];
                    return GestureDetector(
                      onTap: () => _showEditDialog(index,
                          _selectedGroupCode!), // Pass the index and group
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
