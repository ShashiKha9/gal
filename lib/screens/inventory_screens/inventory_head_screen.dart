import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/inventory_screens/view_inwards.dart';
import 'package:galaxy_mini/screens/inventory_screens/view_returns.dart';
import 'package:galaxy_mini/screens/inventory_screens/view_stocks.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class InventoryHeadScreen extends StatefulWidget {
  const InventoryHeadScreen({super.key});

  @override
  State<InventoryHeadScreen> createState() => _InventoryHeadScreenState();
}

class _InventoryHeadScreenState extends State<InventoryHeadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Inventory',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildListTile(
            context,
            icon: Icons.shopping_cart,
            title: 'View Stocks',
            page: const ViewStocks(),
          ),
          _buildListTile(
            context,
            icon: Icons.add_shopping_cart,
            title: 'View Inward',
            page: const ViewInwards(),
          ),
          _buildListTile(
            context,
            icon: Icons.shopping_cart_checkout,
            title: 'View Returns',
            page: const ViewReturns(),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.blue,
        ),
        title: Text(
          title,
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
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
