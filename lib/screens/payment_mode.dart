import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

// Example Option Pages
class PaymentMode extends StatefulWidget {
  const PaymentMode({super.key});

  @override
  State<PaymentMode> createState() => _PaymentModeState();
}

class _PaymentModeState extends State<PaymentMode> {
  late SyncProvider _syncProvider; // List to store table names

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  void _showEditDialog(int index) {
    final selectedmode = _syncProvider.paymentList[index];
    final modeTypeController = TextEditingController(text: selectedmode.type);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit mode type'),
          content: TextField(
            controller: modeTypeController,
            decoration: const InputDecoration(
              labelText: 'Mode Type',
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
                final newType = modeTypeController.text;
                if (newType.isNotEmpty) {
                  setState(() {
                    // Update the table name
                    _syncProvider.paymentList[index].type = newType;
                    // You might want to save the updated list to SharedPreferences or backend
                    // _syncProvider.saveTableNames();
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
        title: 'Payment Master',
        onSearch: (String) {},
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.paymentList.length.toString(),
                  name: 'Consumer length');
              return ListView.builder(
                itemCount: syncProvider.paymentList.length,
                itemBuilder: (context, index) {
                  final payment = syncProvider.paymentList[index];
                  return GestureDetector(
                    onTap: () => _showEditDialog(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
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
                      child: Text(
                        payment.type ?? 'no type',
                        textAlign: TextAlign.left, // Align text to the left
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
