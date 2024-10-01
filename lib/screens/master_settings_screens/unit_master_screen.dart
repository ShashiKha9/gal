import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class UnitMasterScreen extends StatefulWidget {
  const UnitMasterScreen({super.key});

  @override
  State<UnitMasterScreen> createState() => _UnitMasterScreenState();
}

class _UnitMasterScreenState extends State<UnitMasterScreen> {
  late SyncProvider syncProvider;

  @override
  void initState() {
    super.initState();
    syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  void _showEditDialog(int index) {
    // final selectedMode = _syncProvider.paymentList[index];
    // final modeTypeController = TextEditingController(text: selectedMode.type);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Unit Master'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                // controller: modeTypeController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                // controller: modeTypeController,
                decoration: InputDecoration(
                  labelText: 'Remark',
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
                // final newType = modeTypeController.text;
                // if (newType.isNotEmpty) {
                //   setState(() {
                //     _syncProvider.paymentList[index].type = newType;
                //   });
                // }
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
      appBar: const MainAppBar(
        title: 'Unit Master',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) {
                log(syncProvider.unitList.length.toString(),
                    name: 'Consumer length');
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 4.0,
                  ),
                  itemCount: syncProvider.unitList.length,
                  itemBuilder: (context, index) {
                    final unit = syncProvider.unitList[index];
                    return GestureDetector(
                      onTap: () => _showEditDialog(index),
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
                                'Unit: ${unit.unit}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Remark: ${unit.remarks ?? 'No remark'}',
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
              }),
            ),
          ],
        ),
      ),
    );
  }
}
