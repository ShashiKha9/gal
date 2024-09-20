import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customer_credit_detail.dart'; // Ensure this import is correct

class CustomerCredits extends StatefulWidget {
  const CustomerCredits({super.key});

  @override
  _CustomerCreditsState createState() => _CustomerCreditsState();
}

class _CustomerCreditsState extends State<CustomerCredits> {
  List<String> _customerCodes = [];

  @override
  void initState() {
    super.initState();
    _loadCustomerCodes();
  }

  Future<void> _loadCustomerCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? customerCodes = prefs.getStringList('customer_codes');

    if (customerCodes != null) {
      setState(() {
        _customerCodes = customerCodes;
      });
    } else {
      // Handle case where no customer codes are found
      setState(() {
        _customerCodes = [];
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
          ? const Center(child: Text('No customer codes available.'))
          : ListView.builder(
              itemCount: _customerCodes.length,
              itemBuilder: (context, index) {
                String code = _customerCodes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerCreditDetail(
                          customerCode: code,
                          customerName:
                              '', // Pass an empty string or modify if name is available
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
