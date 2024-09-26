import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class BillSettingsScreen extends StatefulWidget {
  const BillSettingsScreen({super.key});

  @override
  State<BillSettingsScreen> createState() => _BillSettingsScreenState();
}

class _BillSettingsScreenState extends State<BillSettingsScreen> {
  bool showPLU = false;
  bool resetBill = false;

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
              title: const Text('Show PLU Option'),
              value: showPLU,
              activeColor: AppColors.blue,
              onChanged: (bool? newValue) {
                setState(() {
                  showPLU = newValue!;
                });
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
              Row(
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 2,
                        groupValue: true,
                        onChanged: (val) {},
                      ),
                      const Text(
                        'Daily',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 2,
                        groupValue: true,
                        onChanged: (val) {},
                      ),
                      const Text(
                        'Monthly',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 2,
                        groupValue: true,
                        onChanged: (val) {},
                      ),
                      const Text(
                        'Yearly',
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Center(
              child: AppButton(
                buttonText: 'Reset Bill No. Menually',
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
