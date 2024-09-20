import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class ArrangeDepartments extends StatefulWidget {
  const ArrangeDepartments({super.key});

  @override
  State<ArrangeDepartments> createState() => _ArrangeDepartmentsState();
}

class _ArrangeDepartmentsState extends State<ArrangeDepartments> {
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
    _syncProvider.getDepartmentsAll().then((_) {
      _syncProvider.loadDepartmentsOrder();
    });
  }

  void _saveOrder() {
    _syncProvider.saveDepartmentsOrder();
    Navigator.of(context).pop();
  }

  void _cancelChanges() {
    _syncProvider.loadDepartmentsOrder();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Arrange Departments',
        isMenu: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Consumer<SyncProvider>(
              builder: (context, syncProvider, child) {
                return ReorderableListView.builder(
                  itemCount: syncProvider.departmentList.length,
                  itemBuilder: (context, index) {
                    final department = syncProvider.departmentList[index];
                    return Card(
                      key: ValueKey(department
                          .code), // Changed to code for better uniqueness
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          department.description ?? 'No description',
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
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final department =
                          _syncProvider.departmentList.removeAt(oldIndex);
                      _syncProvider.departmentList.insert(newIndex, department);
                      _syncProvider
                          .saveDepartmentsOrder(); // Save new order immediately
                    });
                  },
                );
              },
            ),
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
