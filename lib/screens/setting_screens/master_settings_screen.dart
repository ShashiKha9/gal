import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/master_settings_screens/customer_masters/customer_master.dart';
import 'package:galaxy_mini/screens/home_screens/department_screen.dart';
import 'package:galaxy_mini/screens/master_settings_screens/kot_group_master.dart';
import 'package:galaxy_mini/screens/master_settings_screens/kot_message_master.dart';
import 'package:galaxy_mini/screens/master_settings_screens/offer_coupon_masters/offer_coupon_master.dart';
import 'package:galaxy_mini/screens/master_settings_screens/payment_mode_master.dart';
import 'package:galaxy_mini/screens/master_settings_screens/table_master_screen.dart';
import 'package:galaxy_mini/screens/master_settings_screens/tax_master_screen.dart';
import 'package:galaxy_mini/screens/master_settings_screens/unit_master_screen.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class MasterSettingsScreen extends StatelessWidget {
  const MasterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        'icon': Icons.local_dining,
        'title': 'Item Master',
        'page': const DepartmentScreen(isEdit: true)
      },
      {
        'icon': Icons.table_restaurant,
        'title': 'Table Master',
        'page': const TablemasterScreen()
      },
      {
        'icon': Icons.receipt,
        'title': 'Kot Group Master',
        'page': const KotGroupMaster()
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Tax Master',
        'page': const TaxMasterScreen()
      },
      {
        'icon': Icons.workspaces_outline,
        'title': 'Unit Master',
        'page': const UnitMasterScreen()
      },
      {
        'icon': Icons.message,
        'title': 'Kot Message Master',
        'page': const KotMessageMaster()
      },
      {
        'icon': Icons.people,
        'title': 'Customer Master',
        'page': const CustomerMaster()
      },
      {
        'icon': Icons.payment,
        'title': 'Payment Mode Master',
        'page': const PaymentModeMasterScreen()
      },
      {
        'icon': Icons.local_offer,
        'title': 'Offer Coupon Master',
        'page': const OfferCouponMaster()
      },
    ];

    return Scaffold(
      appBar: const MainAppBar(
        title: 'Master Settings',
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
