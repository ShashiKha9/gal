import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/inventory_screens/return_items_screen.dart';

class ViewStocks extends StatefulWidget {
  const ViewStocks({
    super.key,
    this.isEdit = false,
  });
  final bool isEdit;

  @override
  State<ViewStocks> createState() => _ViewStocksState();
}

class _ViewStocksState extends State<ViewStocks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Store Stock",
        isSearch: true,
      ),
      bottomNavigationBar: widget.isEdit
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16)
                  .copyWith(bottom: 25),
              child: AppButton(
                padding: const EdgeInsets.all(10),
                buttonText: "RETURN ITEMS",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReturnItemsScreen(),
                    ),
                  );
                },
              ),
            ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.isEdit ? Navigator.pop(context) : null;
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const ListTile(
                title: Text(
                  "Item Name",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  "0.0",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
