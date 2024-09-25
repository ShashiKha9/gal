import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class UnitMasterScreen extends StatefulWidget {
  const UnitMasterScreen({super.key});

  @override
  State<UnitMasterScreen> createState() => _UnitMasterScreenState();
}

class _UnitMasterScreenState extends State<UnitMasterScreen> {
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        // itemCount: syncProvider.customerList.length,
        itemCount: 1,
        itemBuilder: (context, index) {
          // final customer = syncProvider.customerList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              // leading: const Icon(
              //   Icons.person,
              //   color: AppColors.blue,
              // ),
              title: const Text(
                "Unit: pkt",
                // "${customer.customerCode ?? 'no code'} : ${customer.name ?? 'Unnamed'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    "Remark: null",
                    // 'Mobile: ${customer.mobile1 ?? 'no number'}',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.blue),
                onPressed: () {
                  _showEditDialog(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
