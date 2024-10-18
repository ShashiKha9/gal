import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';

class InwardsDetail extends StatefulWidget {
  const InwardsDetail({super.key});

  @override
  State<InwardsDetail> createState() => _InwardsDetailState();
}

class _InwardsDetailState extends State<InwardsDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Inwards",
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 25),
        child: AppButton(
          padding: const EdgeInsets.all(10),
          buttonText: "CONFIRM",
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: 'Inward Id - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '1234567890',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 05),
                RichText(
                  text: const TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: 'Order Date - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '{date, time}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 05),
                RichText(
                  text: const TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: 'Order Status- ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: 'ACCEPTED',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 05),
                RichText(
                  text: const TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: 'Received on - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '{date, time}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              itemCount: 7,
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
                                labelText: "Qty.",
                                enabled: false,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: AppTextfield(
                                labelText: "Received Qty.",
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
          ),
        ],
      ),
    );
  }
}
