import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

// Example Option Pages
class Kotgroup extends StatefulWidget {
  const Kotgroup({super.key});

  @override
  State<Kotgroup> createState() => _KotgroupState();
}

class _KotgroupState extends State<Kotgroup> {
  late SyncProvider _syncProvider; // List to store table names

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: 'KOT Group Master', onSearch: (String ) {  },),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.kotgroupList.length.toString(),
                  name: 'Consumer length');
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16.0, // Increased spacing for better UI
                  mainAxisSpacing: 16.0, // Increased spacing for better UI
                  childAspectRatio:
                      4.0, // Adjusted aspect ratio for a rectangular shape
                ),
                itemCount: syncProvider.kotgroupList.length,
                itemBuilder: (context, index) {
                  final kotgroup = syncProvider.kotgroupList[index];
                  return GestureDetector(
                    // onTap: () => _onItemTap(item),
                    child: Container(
                      padding: const EdgeInsets.all(
                          16.0), // Added padding for better spacing inside the box
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            12.0), // Softer corners for a modern look
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align text to the start for a cleaner layout
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Name: ${kotgroup.name ?? 'Unnamed Item'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and description
                          Text(
                            'Description: ${kotgroup.description ?? 'No description'}',
                            textAlign: TextAlign.left, // Align text to the left
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
            }),
          ),
        ],
      ),
    );
  }
}
