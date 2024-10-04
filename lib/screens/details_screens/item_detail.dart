import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail({
    super.key,
    this.itemName,
    this.itemShortName,
    this.itemDepartmentCode,
    this.itemKotGroup,
    this.itemRate1,
    this.itemRate2,
    this.itemUnit,
    this.itemGST,
    this.itemBarcode,
    this.itemQRcode,
    this.itemHSN,
    this.itemDisplayInSelection,
    this.itemIsHotItem,
    this.itemQtyInDecimal,
    this.itemIsOpenPrice,
    this.itemHasKOTMessage,
  });

  final String? itemName;
  final String? itemShortName;
  final String? itemDepartmentCode;
  final String? itemKotGroup;
  final String? itemRate1;
  final String? itemRate2;
  final String? itemUnit;
  final String? itemGST;
  final String? itemBarcode;
  final String? itemQRcode;
  final String? itemHSN;
  final String? itemDisplayInSelection;
  final String? itemIsHotItem;
  final String? itemQtyInDecimal;
  final String? itemIsOpenPrice;
  final String? itemHasKOTMessage;

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  String? selectedDepartment;
  String? selectedKOTGroup;
  String? selectedGST;
  String? selectedUnit;

  bool displayInSelection = false;
  bool isHotItem = false;
  bool qtyInDecimal = false;
  bool isOpenPrice = false;
  bool hasKOTMessage = false;

  late TextEditingController nameController;
  late TextEditingController shortNameController;
  late TextEditingController descriptionController =
      TextEditingController(text: '');
  late TextEditingController rate1Controller;
  late TextEditingController rate2Controller;

  late TextEditingController barcodeController;
  late TextEditingController qrCodeController;
  late TextEditingController hsnCodeController;
  late SyncProvider syncProvider;

  @override
  void initState() {
    super.initState();
    syncProvider = Provider.of<SyncProvider>(context, listen: false);

    nameController = TextEditingController(text: widget.itemName ?? '');
    shortNameController =
        TextEditingController(text: widget.itemShortName ?? '');
    rate1Controller = TextEditingController(text: widget.itemRate1 ?? '');
    rate2Controller = TextEditingController(text: widget.itemRate2 ?? '');
    barcodeController = TextEditingController(text: widget.itemBarcode ?? '');
    qrCodeController = TextEditingController(text: widget.itemQRcode ?? '');
    hsnCodeController = TextEditingController(text: widget.itemHSN ?? '');

    selectedDepartment = widget.itemDepartmentCode;
    selectedKOTGroup = widget.itemKotGroup;
    selectedGST = widget.itemGST;
    selectedUnit = widget.itemUnit;
    displayInSelection =
        (widget.itemDisplayInSelection?.toLowerCase() == 'true');
    isHotItem = (widget.itemIsHotItem?.toLowerCase() == 'true');
    qtyInDecimal = (widget.itemQtyInDecimal?.toLowerCase() == 'true');
    isOpenPrice = (widget.itemIsOpenPrice?.toLowerCase() == 'true');
    hasKOTMessage = (widget.itemHasKOTMessage?.toLowerCase() == 'true');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Item Detail',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 5),
            AppTextfield(
              controller: nameController,
              labelText: "Name",
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: shortNameController,
              labelText: 'Short Name',
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: InputDecoration(
                labelText: "Select Department",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: syncProvider.departmentList.map((department) {
                return DropdownMenuItem<String>(
                  value: department.code,
                  child: Text(department.description),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
                log('Selected Department Code: $selectedDepartment');
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedKOTGroup,
              onChanged: (String? newValue) {
                setState(() {
                  selectedKOTGroup = newValue;
                });
                log('Selected KOT Group: $selectedKOTGroup');
              },
              decoration: InputDecoration(
                labelText: "Select KOT Group",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: syncProvider.kotgroupList.map((kotGroup) {
                return DropdownMenuItem<String>(
                  value: kotGroup.code,
                  child: Text(kotGroup.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: rate1Controller,
              labelText: 'Rate 1',
              keyBoardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: rate2Controller,
              labelText: 'Rate 2',
              keyBoardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedGST,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGST = newValue;
                });
                log('Selected GST: $selectedGST');
              },
              decoration: InputDecoration(
                labelText: "Select GST",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: syncProvider.taxList.map((tax) {
                return DropdownMenuItem<String>(
                  value: tax.code,
                  child: Text(tax.name ?? 'Unknown GST'),
                );
              }).toList(),
            ),
            CheckboxListTile(
              title: const Text('Display in Selection'),
              value: displayInSelection,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  displayInSelection = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Is Hot Item'),
              value: isHotItem,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  isHotItem = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Qty in Decimal'),
              value: qtyInDecimal,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  qtyInDecimal = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Is Open Price'),
              value: isOpenPrice,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  isOpenPrice = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Has KOT Message'),
              value: hasKOTMessage,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  hasKOTMessage = newValue!;
                });
              },
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: descriptionController,
              labelText: 'Description',
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedUnit,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue;
                });
                log('Selected unit: $selectedUnit');
              },
              decoration: InputDecoration(
                labelText: 'Select unit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: syncProvider.unitList.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit.code,
                  child: Text(unit.unit ?? 'Unknown unit'),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: barcodeController,
              labelText: 'Barcode',
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: qrCodeController,
              labelText: 'QR Code',
            ),
            const SizedBox(height: 15),
            AppTextfield(
              controller: hsnCodeController,
              labelText: 'HSN Code',
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: AppButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    buttonText: 'Cancel',
                  ),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: AppButton(
                    onTap: () {},
                    buttonText: 'Save',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
