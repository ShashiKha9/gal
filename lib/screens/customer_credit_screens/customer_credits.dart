import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/customer_credit_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:provider/provider.dart'; // Add this for using Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'customer_credit_detail.dart';

class CustomerCredits extends StatefulWidget {
  const CustomerCredits({super.key});

  @override
  _CustomerCreditsState createState() => _CustomerCreditsState();
}

class _CustomerCreditsState extends State<CustomerCredits> {
  List<String> _customerCodes = [];
  Map<String, String> _customerNames = {};
  Map<String, dynamic> _lastBillMap = {}; // Store last bill data
  Map<String, dynamic> _lastPaymentMap = {}; // Store last payment data

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load customer codes
    List<String>? customerCodes = prefs.getStringList('customer_codes');
    if (customerCodes != null) {
      setState(() {
        _customerCodes = customerCodes;
      });
      debugPrint('Loaded customer codes: $_customerCodes');
    } else {
      setState(() {
        _customerCodes = [];
      });
    }

    // Load customer names from SharedPreferences (stored as JSON string)
    String? customerNamesJson = prefs.getString('customer_names');
    if (customerNamesJson != null) {
      Map<String, String> customerNamesMap =
          Map<String, String>.from(jsonDecode(customerNamesJson));
      setState(() {
        _customerNames = customerNamesMap;
      });
      debugPrint('Loaded customer names: $customerNamesMap');
    } else {
      setState(() {
        _customerNames = {};
      });
    }

    // For each customer code, load the last bill and payment details
    for (String customerCode in _customerCodes) {
      await _loadLastBillAndPayment(customerCode);
    }
  }

  Future<void> _loadLastBillAndPayment(String customerCode) async {
    CustomerCreditProvider provider = CustomerCreditProvider();

    // Fetch the bill data for this customer
    List<Map<String, dynamic>> bills =
        await provider.loadBillData(customerCode);
    double totalBillAmount = 0.0;

    if (bills.isNotEmpty) {
      setState(() {
        _lastBillMap[customerCode] = bills.last; // Store the last bill
      });
      // Calculate total bill amount
      for (var bill in bills) {
        totalBillAmount += bill['totalAmount'] ?? 0.0;
      }
    }

    // Fetch the payment data for this customer
    List<Map<String, dynamic>> payments =
        await provider.loadPaymentData(customerCode);
    double totalPaymentAmount = 0.0;

    if (payments.isNotEmpty) {
      setState(() {
        _lastPaymentMap[customerCode] = payments.last; // Store the last payment
      });
      // Calculate total payment amount
      for (var payment in payments) {
        totalPaymentAmount += payment['enteredAmount'] ?? 0.0;
      }
    }

    // Calculate the current balance: Total bills - Total payments
    double currentBalance = totalBillAmount - totalPaymentAmount;

    // Store the current balance in the customer map
    setState(() {
      _lastBillMap[customerCode]['currentBalance'] = currentBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access SyncProvider using Provider.of
    final syncProvider = Provider.of<SyncProvider>(context);

    return Scaffold(
      appBar: MainAppBar(
        title: 'Customer Credits',
        isSearch: true,
        onSearch: (p0) {},
      ),
      body: _customerCodes.isEmpty
          ? const Center(child: Text('No customer data available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _customerCodes.length,
              itemBuilder: (context, index) {
                String code = _customerCodes[index];
                String name = _customerNames[code] ?? 'Unknown';

                // Fetch last bill, payment data, and current balance for this customer
                Map<String, dynamic> lastBill = _lastBillMap[code] ?? {};
                Map<String, dynamic> lastPayment = _lastPaymentMap[code] ?? {};
                double currentBalance = lastBill['currentBalance'] ?? 0.0;

                // Find the customer in customerList using the customerCode
                String? mobileNumber;
                for (var customer in syncProvider.customerList) {
                  if (customer.customerCode == code) {
                    mobileNumber = customer.mobile1 ?? 'N/A';
                    break;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerCreditDetail(
                          customerCode: code,
                          customerName: name,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$name - $mobileNumber", // Display the fetched mobile number
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Display the calculated balance here
                              Text(
                                "₹ ${currentBalance.toStringAsFixed(2)}", // Display the current balance
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Customer Code - #$code",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Last Bill: ${lastBill['billNumber'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Last Payment: ${lastPayment['paymentId'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
