import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON decoding
import 'customer_credit_detail.dart'; // Ensure this import is correct

class CustomerCredits extends StatefulWidget {
  const CustomerCredits({super.key});

  @override
  _CustomerCreditsState createState() => _CustomerCreditsState();
}

class _CustomerCreditsState extends State<CustomerCredits> {
  List<String> _customerCodes = [];
  Map<String, String> _customerNames = {}; // Map to hold customer names

  @override
  void initState() {
    super.initState();
    _loadCustomerData(); // Load both customer codes and names
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
        _customerNames = customerNamesMap; // Store it in a map for easy lookup
      });
      debugPrint('Loaded customer names: $customerNamesMap');
    } else {
      setState(() {
        _customerNames = {}; // Empty map if no names are found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Credits'),
      ),
      body: _customerCodes.isEmpty
          ? const Center(child: Text('No customer data available.'))
          : ListView.builder(
              itemCount: _customerCodes.length,
              itemBuilder: (context, index) {
                String code = _customerCodes[index];
                String name = _customerNames[code] ??
                    'Unknown'; // Use customerNames map to get name

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerCreditDetail(
                          customerCode: code,
                          customerName:
                              name, // Pass the customer name to the next page
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name, // Display customer name
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          code, // Display customer code
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
