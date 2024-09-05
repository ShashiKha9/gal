import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/customer_master.dart';
import 'package:galaxy_mini/screens/department.dart';
import 'package:galaxy_mini/screens/kotgroup_master.dart';
import 'package:galaxy_mini/screens/kot_message.dart';
import 'package:galaxy_mini/screens/offer_coupon.dart';
import 'package:galaxy_mini/screens/payment_mode.dart';
import 'package:galaxy_mini/screens/table_master.dart';
import 'package:galaxy_mini/screens/tax_master.dart';
import 'package:galaxy_mini/screens/unit_master.dart';

class MasterSettingPage extends StatelessWidget {
  const MasterSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        'icon': Icons.local_dining,
        'title': 'Item Master',
        'page': const DepartmentPage(isEdit: true,)
      },
      {
        'icon': Icons.table_restaurant,
        'title': 'Table Master',
        'page': const Tablemaster()
      },
      {
        'icon': Icons.receipt,
        'title': 'Kot Group Master',
        'page': const Kotgroup()
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Tax Master',
        'page': const Taxmaster()
      },
      {
        'icon': Icons.workspaces_outline,
        'title': 'Unit Master',
        'page': const Unitmaster()
      },
      {
        'icon': Icons.message,
        'title': 'Kot Message Master',
        'page': const Kotmessage()
      },
      {
        'icon': Icons.people,
        'title': 'Customer Master',
        'page': const CustomerMaster()
      },
      {
        'icon': Icons.payment,
        'title': 'Payment Mode Master',
        'page': const PaymentMode()
      },
      {
        'icon': Icons.local_offer,
        'title': 'Offer Coupon Master',
        'page': const Offercoupon()
      },
    ];

    return Scaffold(
      appBar: MainAppBar(title: 'Master settings', onSearch: (String ) {  },),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(options[index]['icon']),
            title: Text(options[index]['title']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => options[index]['page'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
