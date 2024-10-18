import 'dart:developer';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_checkbox_tile.dart';
import 'package:galaxy_mini/components/app_dropdown.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/setting_screens/ble_controller.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  String _printerType = 'Bluetooth';
  String _connectionType = 'Bluetooth';
  BluetoothDevice? _selectedDevice;

  bool _printBill = false;
  bool _printShopName = false;
  bool _printLogo = false;
  bool _printAddress = false;
  bool _printGSTNo = false;
  bool _printGreetingMessage = false;
  bool _extraHeader = false;
  bool _extraFooter = true;
  bool _printBillNo = false;
  bool _printDateTime = false;
  bool _printSerialNo = false;
  bool _printHnsCode = false;
  bool _printTaxAmount = false;
  bool _printSubTotal = false;
  bool _printItemCount = false;
  bool _printQuantityCount = false;
  bool _printTaxSymbol = false;
  bool _printDiscount = false;
  bool _printKotMessageInBills = false;
  bool _printCustomerDetail = false;
  bool _printKots = false;
  bool _printShopNameInKots = false;
  bool _printShopAddressInKots = false;
  bool _printShopLogoInKots = false;
  bool _printCustomerInfoInKots = false;
  bool _printTableKots = false;
  bool _printKotMessageInKots = false;
  bool _printGreetingMessageInKots = false;
  bool _duplicateBill = false;
  bool _printPreviousBill = false;
  bool _hotKeyBillPrint = false;
  bool _printTender = false;
  bool _showTenderChange = false;
  bool _showReverseQuantity = false;
  bool _printTwoBillCopies = false;
  bool _autoCutPaper = false;
  final bool _isScanning = false;
  // Track scanning state

  late TextEditingController _shopNameController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _addressLine3Controller;
  late TextEditingController _gstNumberController;
  late TextEditingController _serviceChargesController;
  late TextEditingController _greetingMessageController;
  late TextEditingController _greetingMessageInKotController;
  late TextEditingController _extraHeaderController;
  late TextEditingController _extraFooterController;
  late TextEditingController _feedEndLineController;
  late TextEditingController _billNoController;
  late TextEditingController _taxPercentageController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _addressLine3Controller = TextEditingController();
    _gstNumberController = TextEditingController();
    _serviceChargesController = TextEditingController();
    _greetingMessageController = TextEditingController();
    _greetingMessageInKotController = TextEditingController();
    _extraHeaderController = TextEditingController();
    _extraFooterController = TextEditingController();
    _feedEndLineController = TextEditingController();
    _billNoController = TextEditingController();
    _taxPercentageController = TextEditingController();

    _extraFooterController = TextEditingController(
      text: 'Thank You... Visit Again!',
    );
  }

  void _showBluetoothDevices(BuildContext context) {
    // Get an instance of BleController
    final BleController bleController = Get.put(BleController());

    // Start scanning for devices
    bleController.scanDevices();

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Available Bluetooth Devices"),
          content: GetBuilder<BleController>(
            // No need to initialize again
            builder: (controller) {
              return SizedBox(
                width: double.maxFinite,
                child: Obx(() {
                  final devices = controller.discoveredDevices;
                  if (devices.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device =
                            devices[index]; // Ensure this matches your type
                        return ListTile(
                          title: Text(device.name.isNotEmpty
                              ? device.name
                              : 'Unknown Device'),
                          subtitle: Text(device.id), // Handle nullable ID
                          onTap: () {
                            Navigator.pop(context); // Close the dialog
                            _onDeviceSelected(device);
                            // Use the correct device object here
                            controller.connectToDevice(
                                device); // Pass the selected device
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("No devices found"),
                    );
                  }
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _onDeviceSelected(DiscoveredDevice device) {
    log('Selected device: ${device.name} (${device.id})');
    setState(() {
      _selectedDevice = BluetoothDevice(device.id, device.name);
    });
    // Save the selected printer to persistent storage
    // For example, using shared preferences
    _saveSelectedPrinter(device);
  }

  Future<void> _saveSelectedPrinter(DiscoveredDevice device) async {
    // Use shared preferences to store the selected device details
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPrinterId', device.id);
    await prefs.setString('selectedPrinterName', device.name);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _addressLine3Controller.dispose();
    _gstNumberController.dispose();
    _serviceChargesController.dispose();
    _greetingMessageController.dispose();
    _greetingMessageInKotController.dispose();
    _extraHeaderController.dispose();
    _extraFooterController.dispose();
    _feedEndLineController.dispose();
    _billNoController.dispose();
    _taxPercentageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Printer Settings"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Printer setting
              const Text(
                "Printer Setting",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 25),
              AppDropdown(
                labelText: "Order Status",
                value: _printerType,
                items: const [
                  'Bluetooth',
                  'USB',
                  'Internal',
                ],
                onChanged: (value) {
                  setState(() {
                    _printerType = value!;
                  });
                },
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ['Bluetooth', 'USB', 'Internal'].map((type) {
                  return Expanded(
                    child: RadioListTile<String>(
                      activeColor: AppColors.blue,
                      contentPadding: EdgeInsets.zero,
                      hoverColor: Colors.transparent,
                      title: Text(type),
                      value: type,
                      groupValue: _connectionType,
                      onChanged: (value) {
                        setState(() {
                          _connectionType = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              const Text(
                "Select Bluetooth Device",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),

              _selectedDevice != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDevice!.name?.isNotEmpty == true
                              ? _selectedDevice!.name!
                              : 'Unknown Device',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    )
                  : const Text(
                      "Device Not Selected",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

              const SizedBox(height: 15),
              AppButton(
                buttonText: 'Scan',
                onTap: () {
                  _showBluetoothDevices(context);
                },
              ),

              const SizedBox(height: 25),

              // Printer settings
              const Text(
                "Bill Settings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 10),

              AppCheckboxTile(
                value: _printBill,
                title: "Print Bill",
                onChanged: (value) {
                  setState(() {
                    _printBill = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printShopName,
                title: "Print Shop Name Bill",
                onChanged: (value) {
                  setState(() {
                    _printShopName = value!;
                  });
                },
              ),

              if (_printShopName)
                AppTextfield(
                  controller: _shopNameController,
                  labelText: "Shop Name",
                ),

              AppCheckboxTile(
                value: _printLogo,
                title: "Print Logo in Bill",
                onChanged: (value) {
                  setState(() {
                    _printLogo = value!;
                  });
                },
              ),

              if (_printLogo)
                AppButton(
                  onTap: () {},
                  buttonText: 'Select Image',
                ),

              AppCheckboxTile(
                value: _printAddress,
                title: "Print Address",
                onChanged: (value) {
                  setState(() {
                    _printAddress = value!;
                  });
                },
              ),

              if (_printAddress)
                Column(
                  children: [
                    const SizedBox(),
                    AppTextfield(
                      controller: _addressLine1Controller,
                      labelText: 'Address Line 1',
                    ),
                    AppTextfield(
                      controller: _addressLine2Controller,
                      labelText: 'Address Line 2',
                    ),
                    AppTextfield(
                      controller: _addressLine3Controller,
                      labelText: 'Address Line 3',
                    ),
                  ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: e,
                        ),
                      )
                      .toList(),
                ),

              AppCheckboxTile(
                value: _printGSTNo,
                title: "Print GST No.",
                onChanged: (value) {
                  setState(() {
                    _printGSTNo = value!;
                  });
                },
              ),

              if (_printGSTNo)
                AppTextfield(
                  controller: _gstNumberController,
                  labelText: 'GST Number',
                ),

              const SizedBox(height: 10),

              AppTextfield(
                controller: _serviceChargesController,
                labelText: 'Service Charges (Rs.)',
                keyBoardType: TextInputType.number,
              ),

              AppCheckboxTile(
                value: _printGreetingMessage,
                title: 'Print Greeting Message',
                onChanged: (value) {
                  setState(() {
                    _printGreetingMessage = value!;
                  });
                },
              ),

              if (_printGreetingMessage)
                AppTextfield(
                  controller: _greetingMessageController,
                  labelText: 'Greeting Message',
                ),

              AppCheckboxTile(
                value: _extraHeader,
                title: 'Extra Header',
                onChanged: (value) {
                  setState(() {
                    _extraHeader = value!;
                  });
                },
              ),

              if (_extraHeader)
                AppTextfield(
                  controller: _extraHeaderController,
                  labelText: 'Extra Header',
                ),

              AppCheckboxTile(
                value: _extraFooter,
                title: 'Extra Footer',
                onChanged: (value) {
                  setState(() {
                    _extraFooter = value!;
                  });
                },
              ),

              if (_extraFooter)
                AppTextfield(
                  controller: _extraFooterController,
                  labelText: 'Extra Footer',
                ),

              const SizedBox(height: 10),

              AppTextfield(
                controller: _feedEndLineController,
                labelText: 'Feed End Line',
              ),

              AppCheckboxTile(
                value: _printBillNo,
                title: 'Print Bill No.',
                onChanged: (value) {
                  setState(() {
                    _printBillNo = value!;
                  });
                },
              ),

              if (_printBillNo)
                AppTextfield(
                  controller: _billNoController,
                  labelText: 'Bill No.',
                ),

              AppCheckboxTile(
                value: _printDateTime,
                title: 'Print Date & Time',
                onChanged: (value) {
                  setState(() {
                    _printDateTime = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printSerialNo,
                title: 'Print Serial No.',
                onChanged: (value) {
                  setState(() {
                    _printSerialNo = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printHnsCode,
                title: 'Print HSN Code',
                onChanged: (value) {
                  setState(() {
                    _printHnsCode = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printTaxAmount,
                title: 'Print Tax Ammount',
                onChanged: (value) {
                  setState(() {
                    _printTaxAmount = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printSubTotal,
                title: 'Print Sub-Total',
                onChanged: (value) {
                  setState(() {
                    _printSubTotal = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printItemCount,
                title: 'Print Item Count',
                onChanged: (value) {
                  setState(() {
                    _printItemCount = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printQuantityCount,
                title: 'Print Quantity Count',
                onChanged: (value) {
                  setState(() {
                    _printQuantityCount = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printTaxSymbol,
                title: 'Print Tax Symbol',
                onChanged: (value) {
                  setState(() {
                    _printTaxSymbol = value!;
                  });
                },
              ),

              AppTextfield(
                controller: _taxPercentageController,
                labelText: 'Enter Tax Percentage',
              ),

              AppCheckboxTile(
                value: _printDiscount,
                title: 'Print Discount',
                onChanged: (value) {
                  setState(() {
                    _printDiscount = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printKotMessageInBills,
                title: 'Print KOT Message in Bills',
                onChanged: (value) {
                  setState(() {
                    _printKotMessageInBills = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printCustomerDetail,
                title: 'Print Customer Details',
                onChanged: (value) {
                  setState(() {
                    _printCustomerDetail = value!;
                  });
                },
              ),

              const SizedBox(height: 25),

              // KOT settings
              const Text(
                "KOT Settings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 10),

              AppCheckboxTile(
                value: _printKots,
                title: 'Print KOTs',
                onChanged: (value) {
                  setState(() {
                    _printKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printShopNameInKots,
                title: 'Print Shop Name in KOTs',
                onChanged: (value) {
                  setState(() {
                    _printShopNameInKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printShopAddressInKots,
                title: 'Print Shop Address in KOTs',
                onChanged: (value) {
                  setState(() {
                    _printShopAddressInKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printShopLogoInKots,
                title: 'Print Shop Logo in KOTs',
                onChanged: (value) {
                  setState(() {
                    _printShopLogoInKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printCustomerInfoInKots,
                title: 'Print Customer info in KOTs',
                onChanged: (value) {
                  setState(() {
                    _printCustomerInfoInKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printTableKots,
                title: 'Print Table KOTs',
                onChanged: (value) {
                  setState(() {
                    _printTableKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printKotMessageInKots,
                title: 'Print KOT Message in KOTs',
                onChanged: (value) {
                  setState(() {
                    _printKotMessageInKots = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printGreetingMessageInKots,
                title: 'Print Greeting Message in KOTs',
                onChanged: (value) {
                  setState(() {
                    _printGreetingMessageInKots = value!;
                  });
                },
              ),

              if (_printGreetingMessageInKots)
                AppTextfield(
                  controller: _greetingMessageController,
                  labelText: 'Greeting Message',
                ),

              const SizedBox(height: 25),

              // Printer settings
              const Text(
                "Printer Settings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 10),

              AppCheckboxTile(
                value: _duplicateBill,
                title: 'Duplicate Bill',
                onChanged: (value) {
                  setState(() {
                    _duplicateBill = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printPreviousBill,
                title: 'Print Previouse Bill',
                onChanged: (value) {
                  setState(() {
                    _printPreviousBill = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _hotKeyBillPrint,
                title: 'Hot Key Bill Print',
                onChanged: (value) {
                  setState(() {
                    _hotKeyBillPrint = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printTender,
                title: 'Print Tender',
                onChanged: (value) {
                  setState(() {
                    _printTender = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _showTenderChange,
                title: 'Show Tender Change',
                onChanged: (value) {
                  setState(() {
                    _showTenderChange = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _showReverseQuantity,
                title: 'Show Reverse Quantity',
                onChanged: (value) {
                  setState(() {
                    _showReverseQuantity = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _printTwoBillCopies,
                title: 'Print Two Bill Copies',
                onChanged: (value) {
                  setState(() {
                    _printTwoBillCopies = value!;
                  });
                },
              ),

              AppCheckboxTile(
                value: _autoCutPaper,
                title: 'Auto Cut Paper',
                onChanged: (value) {
                  setState(() {
                    _autoCutPaper = value!;
                  });
                },
              ),

              const SizedBox(height: 25),

              AppButton(
                onTap: _submitForm,
                buttonText: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
