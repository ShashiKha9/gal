import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';

class EditCouponPage extends StatefulWidget {
  final String couponCode;
  final String note;
  final String discountInPercent;
  final String maxDiscount;
  final String minBillAmount;
  final String validity;
  final int couponIndex;

  const EditCouponPage({
    super.key,
    required this.couponCode,
    required this.note,
    required this.discountInPercent,
    required this.maxDiscount,
    required this.minBillAmount,
    required this.validity,
    required this.couponIndex,
  });

  @override
  _EditCouponPageState createState() => _EditCouponPageState();
}

class _EditCouponPageState extends State<EditCouponPage> {
  late TextEditingController _couponCodeController;
  late TextEditingController _noteController;
  late TextEditingController _discountInPercentController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _minBillAmountController;
  late TextEditingController _validityController;

  @override
  void initState() {
    super.initState();
    _couponCodeController = TextEditingController(text: widget.couponCode);
    _noteController = TextEditingController(text: widget.note);
    _discountInPercentController =
        TextEditingController(text: widget.discountInPercent);
    _maxDiscountController = TextEditingController(text: widget.maxDiscount);
    _minBillAmountController =
        TextEditingController(text: widget.minBillAmount);
    _validityController = TextEditingController(text: widget.validity);
  }

  @override
  void dispose() {
    _couponCodeController.dispose();
    _noteController.dispose();
    _discountInPercentController.dispose();
    _maxDiscountController.dispose();
    _minBillAmountController.dispose();
    _validityController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    // Call the updateOffer method to update the coupon details
    syncProvider.updateOffer(
      syncProvider.offerList[widget.couponIndex]
          .offerCouponId, // Existing offerCouponId
      _couponCodeController.text,
      _noteController.text,
      _discountInPercentController.text,
      _maxDiscountController.text,
      _minBillAmountController.text,
      _validityController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Edit Coupon",
        isMenu: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            AppTextfield(
              controller: _couponCodeController,
              labelText: 'Coupon Code',
            ),
            AppTextfield(
              controller: _noteController,
              labelText: 'Note',
            ),
            AppTextfield(
              controller: _discountInPercentController,
              labelText: 'Discount in Percent',
            ),
            AppTextfield(
              controller: _maxDiscountController,
              labelText: 'Max Discount',
            ),
            AppTextfield(
              controller: _minBillAmountController,
              labelText: 'Min Bill Amount',
            ),
            AppTextfield(
              controller: _validityController,
              labelText: 'Validity',
            ),
          ]
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: e,
                ),
              )
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChanges,
        child: const Icon(Icons.save),
      ),
    );
  }
}
