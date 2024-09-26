import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
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
  bool _isDataSynced = false;

  @override
  void initState() {
    super.initState();
    _checkIfDataFetched();
  }

  Future<void> _checkIfDataFetched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDataFetched = prefs.getBool('is_customer_credit_fetched') ?? false;

    if (isDataFetched) {
      // Load data if already fetched
      _loadCustomerData();
    } else {
      setState(() {
        _customerCodes = []; // No data available
        _customerNames = {};
      });
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Customer Credits',
      ),
      body: _customerCodes.isEmpty
          ? const Center(child: Text('No customer data available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _customerCodes.length,
              itemBuilder: (context, index) {
                String code = _customerCodes[index];
                String name = _customerNames[code] ?? 'Unknown';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          code,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
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
                  ),
                );
              },
            ),
    );
  }
}
