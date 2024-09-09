import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

// Example Option Pages
class Kotmessage extends StatefulWidget {
  const Kotmessage({super.key});

  @override
  State<Kotmessage> createState() => _KotmessageState();
}

class _KotmessageState extends State<Kotmessage> {
  late SyncProvider _syncProvider; // List to store table names

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  void _showEditDialog(int index) {
    final selectedKotmessage = _syncProvider.kotmessageList[index];
    final kotMessageController =
        TextEditingController(text: selectedKotmessage.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit kot description'),
          content: TextField(
            controller: kotMessageController,
            decoration: const InputDecoration(
              labelText: 'KOT Message',
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
                final newMessage = kotMessageController.text;
                if (newMessage.isNotEmpty) {
                  setState(() {
                    // Update the kotmessage description
                    _syncProvider.kotmessageList[index].description =
                        newMessage;
                    // You might want to save the updated list to SharedPreferences or backend
                    // _syncProvider.saveKotmessages();
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
      appBar: AppBar(
        title: const Text('KOT Message Master'),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.kotmessageList.length.toString(),
                  name: 'Consumer length');
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 4.0,
                ),
                itemCount: syncProvider.kotmessageList.length,
                itemBuilder: (context, index) {
                  final kotmessage = syncProvider.kotmessageList[index];
                  return GestureDetector(
                    onTap: () => _showEditDialog(
                        index), // Pass the index to showEditDialog
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
                            'Description: ${kotmessage.description ?? 'No description'}',
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
