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
  late SyncProvider _syncProvider;
  String? _selectedGroupCode; // Track the selected group code

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _fetchData();
  }

  // Fetch data and organize tables by group
  Future<void> _fetchData() async {
    await _syncProvider.fetchAndOrganizeTables();
    setState(() {}); // Refresh the UI after fetching data
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
        onSearch: (String) {},
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
          // Display ChoiceChips for each table group
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: syncProvider.tablesByGroup.keys.map((groupCode) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text('Group $groupCode'),
                        selected: _selectedGroupCode == groupCode,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGroupCode = selected ? groupCode : null;
                          });
                        },
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
