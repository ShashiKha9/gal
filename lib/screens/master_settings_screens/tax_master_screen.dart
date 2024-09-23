import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

class TaxMasterScreen extends StatefulWidget {
  const TaxMasterScreen({super.key});

  @override
  State<TaxMasterScreen> createState() => _TaxMasterScreenState();
}

class _TaxMasterScreenState extends State<TaxMasterScreen> {
  late SyncProvider _syncProvider;

  // Declare a variable to hold the selected GST type
  String _selectedGstType = 'Inclusive'; // Default value

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  // Function to show the alert dialog for selecting GST type
  void _showGstTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Use a temporary variable to store the current selection
        String tempSelectedGstType = _selectedGstType;

        return AlertDialog(
          title: const Text('Select GST Type'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Inclusive'),
                    value: 'Inclusive',
                    groupValue: tempSelectedGstType,
                    onChanged: (value) {
                      setDialogState(() {
                        tempSelectedGstType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Exclusive'),
                    value: 'Exclusive',
                    groupValue: tempSelectedGstType,
                    onChanged: (value) {
                      setDialogState(() {
                        tempSelectedGstType = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without changes
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the main screen with the new selection
                setState(() {
                  _selectedGstType = tempSelectedGstType;
                });
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
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
        title: 'Tax Master',
        isMenu: false,
        onSearch: (value) {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the selected GST type at the top and make it clickable
            GestureDetector(
              onTap: _showGstTypeDialog, // Open the dialog on tap
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Selected GST Type: $_selectedGstType',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Make it look clickable
                  ),
                ),
              ),
            ),

            // Tax list display
            Expanded(
              child: Consumer<SyncProvider>(
                builder: (context, syncProvider, child) {
                  log(syncProvider.taxList.length.toString(),
                      name: 'Tax List Length');
                  return ListView.builder(
                    itemCount: syncProvider.taxList.length,
                    itemBuilder: (context, index) {
                      final tax = syncProvider.taxList[index];
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'GST Code: ${tax.code ?? 'No Code'}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'GST Name: ${tax.name ?? 'Unnamed'}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total GST Rate: ${tax.rate ?? 'No Rate'}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'CGst Rate: ${tax.cGst ?? 'No CGst'}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'SGst Rate: ${tax.sgst ?? 'No SGst'}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'IGst Rate: ${tax.iGst ?? 'No IGst'}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
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
          ],
        ),
      ),
    );
  }
}
