import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillSettingsScreen extends StatefulWidget {
  const BillSettingsScreen({super.key});

  @override
  State<BillSettingsScreen> createState() => _BillSettingsScreenState();
}

class _BillSettingsScreenState extends State<BillSettingsScreen> {
  bool showPLU = false;
  bool resetBill = false;
  bool startBill = false;
  String? selectedFrequency;

  final TextEditingController billNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShowPLU();
  }

  Future<void> _loadShowPLU() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showPLU = prefs.getBool('showPLU') ?? false; // Load saved state
    });
  }

  Future<void> _saveShowPLU(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showPLU', value);
  } // To hold the selected frequency

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Bill Setting",
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Start Bill Number From'),
              value: startBill,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  startBill = newValue!;
                });
              },
            ),
            if (startBill)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AppTextfield(
                  controller: billNumberController,
                  labelText: "Start Bill Number From",
                ),
              ),
            CheckboxListTile(
              title: const Text('Show PLU Option'),
              value: showPLU,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  showPLU = newValue!;
                  _saveShowPLU(newValue);
                });
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Reset Bill Periodically'),
              value: resetBill,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  resetBill = newValue!;
                });
              },
            ),
            if (resetBill == true)
              Column(
                children: [
                  ListTile(
                    title: const Text('Daily'),
                    leading: Radio<String>(
                      value: 'Daily',
                      groupValue: selectedFrequency,
                      onChanged: (String? value) {
                        setState(() {
                          selectedFrequency = value;
                          _setResetFrequency(value);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Monthly'),
                    leading: Radio<String>(
                      value: 'Monthly',
                      groupValue: selectedFrequency,
                      onChanged: (String? value) {
                        setState(() {
                          selectedFrequency = value;
                          _setResetFrequency(value);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Yearly'),
                    leading: Radio<String>(
                      value: 'Yearly',
                      groupValue: selectedFrequency,
                      onChanged: (String? value) {
                        setState(() {
                          selectedFrequency = value;
                          _setResetFrequency(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Center(
              child: AppButton(
                buttonText: 'Reset Bill No. Manually',
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                onTap: _resetBillNumber, // Call the reset function
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setResetFrequency(String? frequency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('billResetFrequency', frequency!);

    // Store the current timestamp as the last reset time
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastResetTime', currentTime);

    // Logic to reset the bill number based on frequency
    if (frequency == 'Daily') {
      // Schedule a daily reset
      _scheduleDailyReset();
    } else if (frequency == 'Monthly') {
      // Schedule a monthly reset
      _scheduleMonthlyReset();
    } else if (frequency == 'Yearly') {
      // Schedule a yearly reset
      _scheduleYearlyReset();
    }
  }

// Function to check and reset the bill number if daily period has passed
  Future<void> _scheduleDailyReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastResetTime = prefs.getInt('lastResetTime') ?? 0;

    // Calculate the difference in days
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if ((currentTime - lastResetTime) >= 86400000) {
      // 24 hours in milliseconds
      await _resetBillNumber(); // Reset bill number to 1
      await prefs.setInt(
          'lastResetTime', currentTime); // Update the last reset time
    }
  }

// Function to check and reset the bill number if monthly period has passed
  Future<void> _scheduleMonthlyReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastResetTime = prefs.getInt('lastResetTime') ?? 0;

    // Check if a month has passed
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DateTime lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTime);
    if (DateTime.now().difference(lastResetDate).inDays >= 30) {
      await _resetBillNumber(); // Reset bill number to 1
      await prefs.setInt(
          'lastResetTime', currentTime); // Update the last reset time
    }
  }

// Function to check and reset the bill number if yearly period has passed
  Future<void> _scheduleYearlyReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastResetTime = prefs.getInt('lastResetTime') ?? 0;

    // Check if a year has passed
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DateTime lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTime);
    if (DateTime.now().difference(lastResetDate).inDays >= 365) {
      await _resetBillNumber(); // Reset bill number to 1
      await prefs.setInt(
          'lastResetTime', currentTime); // Update the last reset time
    }
  }

  Future<void> _resetBillNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentBillNumber', 1); // Reset to 1
    log('Bill number reset to 1'); // Log statement to see the change
  }
}
