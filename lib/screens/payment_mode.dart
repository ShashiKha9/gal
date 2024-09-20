import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class PaymentMode extends StatefulWidget {
  const PaymentMode({super.key});

  @override
  State<PaymentMode> createState() => _PaymentModeState();
}

class _PaymentModeState extends State<PaymentMode> {
  late SyncProvider _syncProvider;
  int _selectedPaymentIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(
        msg: "Please select default from the list",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Payment Master',
        isMenu: false,
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  leading: Icon(
                    _getPaymentIcon(payment.type ?? 'Others'),
                    color: AppColors.blue,
                  ),
                  title: Text(
                    payment.type ?? 'No type',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: _selectedPaymentIndex == index
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
                      : null,
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
              leading: const Icon(
                Icons.more_horiz,
                color: AppColors.blue,
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
    );
  }
}


  // void _showEditDialog(int index) {
  //   final selectedMode = _syncProvider.paymentList[index];
  //   final modeTypeController = TextEditingController(text: selectedMode.type);

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Mode Type'),
  //         content: TextField(
  //           controller: modeTypeController,
  //           decoration: const InputDecoration(
  //             labelText: 'Mode Type',
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               final newType = modeTypeController.text;
  //               if (newType.isNotEmpty) {
  //                 setState(() {
  //                   _syncProvider.paymentList[index].type = newType;
  //                 });
  //               }
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
