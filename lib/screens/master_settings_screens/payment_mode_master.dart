import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class PaymentModeMasterScreen extends StatefulWidget {
  const PaymentModeMasterScreen({super.key});

  @override
  State<PaymentModeMasterScreen> createState() =>
      _PaymentModeMasterScreenState();
}

class _PaymentModeMasterScreenState extends State<PaymentModeMasterScreen> {
  late SyncProvider _syncProvider;
  int _selectedPaymentIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // scaffoldMessage(message: 'Please select default from the list');
    // });
  }

  void _showDefaultPaymentDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Default Payment Mode'),
          content: const Text(
              'Do you want to set this as the default payment mode?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPaymentIndex = index;
                });
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.currency_rupee;
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.phone_android;
      case 'credit party':
        return Icons.group;
      default:
        return Icons.more_horiz;
    }
  }

  void _showEditDialog(int index) {
    final selectedMode = _syncProvider.paymentList[index];
    final modeTypeController = TextEditingController(text: selectedMode.type);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Mode Type'),
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
                    _syncProvider.paymentList[index].type = newType;
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
      appBar: const MainAppBar(
        title: 'Payment Master',
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
              child: const Row(
                children: [
                  Text("Please select default from the list"),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _syncProvider.paymentList.length,
              itemBuilder: (context, index) {
                final payment = _syncProvider.paymentList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentIcon(payment.type),
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    title: Text(
                      payment.type,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _selectedPaymentIndex == index
                            ? Radio<int>(
                                value: index,
                                groupValue: _selectedPaymentIndex,
                                activeColor: AppColors.blue,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    _showDefaultPaymentDialog(value);
                                  }
                                },
                              )
                            : const SizedBox(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.blue),
                          onPressed: () {
                            _showEditDialog(index); // Pass the index
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _showDefaultPaymentDialog(index);
                    },
                  ),
                );
              },
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                leading: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.more_horiz,
                      color: AppColors.blue,
                    ),
                    SizedBox(width: 10), // Adds spacing between the icons
                  ],
                ),
                title: const Text(
                  'Others',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing:
                    _selectedPaymentIndex == _syncProvider.paymentList.length
                        ? Radio<int>(
                            value: _syncProvider.paymentList.length,
                            groupValue: _selectedPaymentIndex,
                            activeColor: AppColors.blue,
                            onChanged: (int? value) {
                              if (value != null) {
                                _showDefaultPaymentDialog(value);
                              }
                            },
                          )
                        : null,
                onTap: () {
                  _showDefaultPaymentDialog(_syncProvider.paymentList.length);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
