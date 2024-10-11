import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.itemCode,
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
  final String? itemCode;

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

    _loadPreferences();
  }

  // Load the preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String itemCode = widget.itemCode ?? 'unknown_item';

    setState(() {
      // Check if the preference exists before setting the state
      if (prefs.containsKey('display_in_selection_$itemCode')) {
        displayInSelection = prefs.getBool('display_in_selection_$itemCode') ??
            displayInSelection;
      }
      if (prefs.containsKey('is_hot_item_$itemCode')) {
        isHotItem = prefs.getBool('is_hot_item_$itemCode') ?? isHotItem;
      }
      if (prefs.containsKey('qty_in_decimal_$itemCode')) {
        qtyInDecimal =
            prefs.getBool('qty_in_decimal_$itemCode') ?? qtyInDecimal;
      }
      if (prefs.containsKey('is_open_price_$itemCode')) {
        isOpenPrice = prefs.getBool('is_open_price_$itemCode') ?? isOpenPrice;
      }
      if (prefs.containsKey('has_kot_message_$itemCode')) {
        hasKOTMessage =
            prefs.getBool('has_kot_message_$itemCode') ?? hasKOTMessage;
      }
    });
  }

// Inside the _ItemDetailState class
  void _saveEditItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String itemCode = widget.itemCode ?? 'unknown_item';

    // Log for debugging
    log('Saving data for itemCode: $itemCode');

    // Save each field
    await prefs.setString('name_$itemCode', nameController.text);
    log('Saved name for $itemCode: ${nameController.text}');

    // Continue saving other fields
    await prefs.setString('short_name_$itemCode', shortNameController.text);
    await prefs.setString('department_$itemCode', selectedDepartment ?? '');
    await prefs.setString('kot_group_$itemCode', selectedKOTGroup ?? '');
    await prefs.setString('rate1_$itemCode', rate1Controller.text);
    await prefs.setString('rate2_$itemCode', rate2Controller.text);
    await prefs.setString('barcode_$itemCode', barcodeController.text);
    await prefs.setString('qrcode_$itemCode', qrCodeController.text);
    await prefs.setString('hsn_$itemCode', hsnCodeController.text);
    await prefs.setString('gst_$itemCode', selectedGST ?? '');
    await prefs.setString('unit_$itemCode', selectedUnit ?? '');

    // Save boolean values for checkbox options
    await prefs.setBool('display_in_selection_$itemCode', displayInSelection);
    await prefs.setBool('is_hot_item_$itemCode', isHotItem);
    await prefs.setBool('qty_in_decimal_$itemCode', qtyInDecimal);
    await prefs.setBool('is_open_price_$itemCode', isOpenPrice);
    await prefs.setBool('has_kot_message_$itemCode', hasKOTMessage);

    log('Item changes saved to SharedPreferences for itemCode: $itemCode.');
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
              onChanged: (String? newValue) {
                setState(() {
                  selectedKOTGroup = newValue;
                });
                log('Selected KOT Group: $selectedKOTGroup');
              },
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
              onChanged: (bool? value) {
                setState(() {
                  displayInSelection = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Is Hot Item'),
              value: isHotItem,
              activeColor: AppColors.blue,
              onChanged: (bool? value) {
                setState(() {
                  isHotItem = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Qty in Decimal'),
              value: qtyInDecimal,
              activeColor: AppColors.blue,
              onChanged: (bool? value) {
                setState(() {
                  qtyInDecimal = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Is Open Price'),
              value: isOpenPrice,
              activeColor: AppColors.blue,
              onChanged: (bool? value) {
                setState(() {
                  isOpenPrice = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Has KOT Message'),
              value: hasKOTMessage,
              activeColor: AppColors.blue,
              onChanged: (bool? value) {
                setState(() {
                  hasKOTMessage = value ?? false;
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
                AppButton(
                  onTap: () {
                    _saveEditItem(); // Save the changes
                    Navigator.pop(context); // Close the page after saving
                  },
                  buttonText: 'Save',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
