import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/inventory_screens/view_stocks.dart';

class ReturnItemsScreen extends StatefulWidget {
  const ReturnItemsScreen({super.key});

  @override
  State<ReturnItemsScreen> createState() => _ReturnItemsScreenState();
}

class _ReturnItemsScreenState extends State<ReturnItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Return Items",
        actionWidget: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewStocks(isEdit: true),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
        actions: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AppButton(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.black54,
                buttonText: "CANCEL",
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                padding: const EdgeInsets.all(10),
                buttonText: "RETURN",
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Item Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextfield(
                          labelText: "In Stock",
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AppTextfield(
                          labelText: "Return Qty.",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
