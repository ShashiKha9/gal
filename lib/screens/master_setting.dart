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
import 'package:galaxy_mini/theme/app_colors.dart';

class MasterSettingPage extends StatelessWidget {
  const MasterSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        'icon': Icons.local_dining,
        'title': 'Item Master',
        'page': const DepartmentPage(isEdit: true)
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
      appBar: const MainAppBar(
        title: 'Master Settings',
        isMenu: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            elevation: 2,
            child: ListTile(
              leading: Icon(
                options[index]['icon'],
                color: AppColors.blue,
              ),
              title: Text(
                options[index]['title'],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => options[index]['page'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
