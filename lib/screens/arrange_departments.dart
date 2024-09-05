import 'dart:developer';
import 'package:flutter/material.dart';
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
      _syncProvider.loadDepartmentsOrder(); // Load saved order
    });
  }

  void _saveOrder() {
    _syncProvider.saveDepartmentsOrder(); // Save order to SharedPreferences
    Navigator.of(context).pop(); // Navigate back or close the screen
  }

  void _cancelChanges() {
    _syncProvider.loadDepartmentsOrder(); // Reload the saved order to discard changes
    Navigator.of(context).pop(); // Navigate back or close the screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arrange Departments')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              return ReorderableListView.builder(
                itemCount: syncProvider.departmentList.length,
                itemBuilder: (context, index) {
                  final department = syncProvider.departmentList[index];
                  return Container(
                    key: ValueKey(department.code), // Changed to code for better uniqueness
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
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
                    child: Text(
                      department.description ?? 'No description',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
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
                    _syncProvider.saveDepartmentsOrder(); // Save new order immediately
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
