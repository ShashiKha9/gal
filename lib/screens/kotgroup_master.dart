import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class Kotgroup extends StatefulWidget {
  const Kotgroup({super.key});

  @override
  State<Kotgroup> createState() => _KotgroupState();
}

class _KotgroupState extends State<Kotgroup> {
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
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
                return Card(
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
                          'Name: ${kotgroup.name ?? 'Unnamed Item'}',
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
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
