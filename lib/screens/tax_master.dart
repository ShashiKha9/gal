import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

// Example Option Pages
class Taxmaster extends StatefulWidget {
  const Taxmaster({super.key});

  @override
  State<Taxmaster> createState() => _TaxmasterState();
}

class _TaxmasterState extends State<Taxmaster> {
  late SyncProvider _syncProvider; // List to store table names

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: 'Tax Master', onSearch: (String ) {  },),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.taxList.length.toString(),
                  name: 'Consumer length');
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Number of items per row
                  crossAxisSpacing: 16.0, // Increased spacing for better UI
                  mainAxisSpacing: 16.0, // Increased spacing for better UI
                  childAspectRatio:
                      1.9, // Adjusted aspect ratio for larger boxes
                ),
                itemCount: syncProvider.taxList.length,
                itemBuilder: (context, index) {
                  final tax = syncProvider.taxList[index];
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
                            'GST Code: ${tax.code ?? 'no code'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and description
                          Text(
                            'GST Name: ${tax.name ?? 'Unnamed'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and description
                          Text(
                            'Total GST Rate: ${tax.rate ?? 'no rate'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and description
                          Text(
                            'CGst Rate: ${tax.cGst ?? 'no CGst'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and description
                          Text(
                            'SGst Rate: ${tax.sgst ?? 'No SGst'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and description
                          Text(
                            'IGst Rate: ${tax.iGst ?? 'No IGst'}',
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
