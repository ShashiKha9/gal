import 'dart:developer';

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

    final screenSize = MediaQuery.of(context).size;
    double cardHeight = MediaQuery.of(context).size.height;
    int crossAxisCount;
    double childAspectRatio;
    log(screenSize.toString(), name: "screenSize");

    if (screenSize.width > 1200) {
      crossAxisCount = 10;
      childAspectRatio = (cardHeight / crossAxisCount) / 95;
      log(screenSize.toString(), name: "1200");
    } else if (screenSize.width > 1000) {
      crossAxisCount = 8;
      childAspectRatio = (cardHeight / crossAxisCount) / 95;
      log(screenSize.toString(), name: "1000");
    } else if (screenSize.width > 800 || screenSize.width >= 800) {
      crossAxisCount = 4;
      childAspectRatio = (cardHeight / crossAxisCount) / 250;
      log(screenSize.toString(), name: "800");
    } else {
      crossAxisCount = 3;
      childAspectRatio = (cardHeight / crossAxisCount) / 300;
      log(screenSize.toString(), name: "00");
    }

    return Scaffold(
      appBar: const MainAppBar(
        title: 'Master Settings',
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: options.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => options[index]['page'],
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              elevation: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    options[index]['icon'],
                    color: AppColors.blue,
                    size: 35,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    options[index]['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // child: ListTile(
              //   leading: Icon(
              //     options[index]['icon'],
              //     color: AppColors.blue,
              //   ),
              //   title: Text(
              //     options[index]['title'],
              //     style: const TextStyle(
              //       color: Colors.black,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              //   contentPadding:
              //       const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => options[index]['page'],
              //       ),
              //     );
              //   },
              // ),
            ),
          );
        },
      ),
    );
  }
}
