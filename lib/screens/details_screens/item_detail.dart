import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
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
  // String? selectedUnit;

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
  // late TextEditingController descriptionController;
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

    // Pre-select the department and KOT group based on item data
    selectedDepartment = widget.itemDepartmentCode;
    selectedKOTGroup = widget.itemKotGroup;
    selectedGST = widget.itemGST;
    // selectedUnit = widget.itemUnit;
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
      appBar: AppBar(
        title: const Text('Item Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Name TextField
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: nameController,
                labelText: "Name",
              ),
            ),

            // Short Name TextField
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: shortNameController,
                labelText: 'Short Name',
              ),
            ),

            // Department Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Select Department',
                  border: OutlineInputBorder(),
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
            ),

            // KOT Group Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                value: selectedKOTGroup,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedKOTGroup = newValue;
                  });
                  log('Selected KOT Group: $selectedKOTGroup');
                },
                decoration:
                    const InputDecoration(labelText: 'Select KOT Group'),
                items: syncProvider.kotgroupList.map((kotGroup) {
                  return DropdownMenuItem<String>(
                    value: kotGroup.code,
                    child: Text(kotGroup.name),
                  );
                }).toList(),
              ),
            ),

            // Rate 1 AppTextfield
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: rate1Controller,
                labelText: 'Rate 1',
                keyBoardType: TextInputType.number,
              ),
            ),

            // Rate 2 AppTextfield
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: rate2Controller,
                labelText: 'Rate 2',
                keyBoardType: TextInputType.number,
              ),
            ),

            // GST Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                value: selectedGST,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGST = newValue;
                  });
                  log('Selected GST: $selectedGST');
                },
                decoration: const InputDecoration(labelText: 'Select GST'),
                items: syncProvider.taxList.map((tax) {
                  return DropdownMenuItem<String>(
                    value: tax.code,
                    child: Text(tax.name ?? 'Unknown GST'),
                  );
                }).toList(),
              ),
            ),

            // Checkboxes
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CheckboxListTile(
                title: const Text('Display in Selection'),
                value: displayInSelection,
                onChanged: (bool? newValue) {
                  setState(() {
                    displayInSelection = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CheckboxListTile(
                title: const Text('Is Hot Item'),
                value: isHotItem,
                onChanged: (bool? newValue) {
                  setState(() {
                    isHotItem = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CheckboxListTile(
                title: const Text('Qty in Decimal'),
                value: qtyInDecimal,
                onChanged: (bool? newValue) {
                  setState(() {
                    qtyInDecimal = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CheckboxListTile(
                title: const Text('Is Open Price'),
                value: isOpenPrice,
                onChanged: (bool? newValue) {
                  setState(() {
                    isOpenPrice = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CheckboxListTile(
                title: const Text('Has KOT Message'),
                value: hasKOTMessage,
                onChanged: (bool? newValue) {
                  setState(() {
                    hasKOTMessage = newValue!;
                  });
                },
              ),
            ),

            // Description AppTextfield
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: descriptionController,
                labelText: 'Description',
              ),
            ),

            // Barcode AppTextfield
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: barcodeController,
                labelText: 'Barcode',
              ),
            ),

            // QR Code AppTextfield
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: qrCodeController,
                labelText: 'QR Code',
              ),
            ),

            // HSN Code AppTextfield
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppTextfield(
                controller: hsnCodeController,
                labelText: 'HSN Code',
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Save logic here
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save logic here
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
