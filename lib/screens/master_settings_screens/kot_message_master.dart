import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class KotMessageMaster extends StatefulWidget {
  const KotMessageMaster({super.key});

  @override
  State<KotMessageMaster> createState() => _KotMessageMasterState();
}

class _KotMessageMasterState extends State<KotMessageMaster> {
  late SyncProvider _syncProvider;

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
          title: const Text('Edit KOT Description'),
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
                    _syncProvider.kotmessageList[index].description =
                        newMessage;
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

  void _showAddDialog() {
    final kotMessageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add KOT Message'),
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
                  // Use the addKotMessage function from the provider
                  _syncProvider.addKotMessage(newMessage);
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
        backgroundColor: AppColors.lightPink,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) {
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
                      onTap: () => _showEditDialog(index),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            'Description: ${kotmessage.description ?? 'No description'}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.edit,
                            color: AppColors.blue,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Assuming KotMessage is your model class
class KotMessage {
  String description;

  KotMessage({required this.description});
}
