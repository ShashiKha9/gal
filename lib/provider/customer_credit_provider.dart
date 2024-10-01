import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerCreditProvider extends ChangeNotifier {
  static const _billNumberKey = 'billNumber';
  static const _paymentIdKey = 'paymentId';
  List<Map<String, dynamic>> _cashPayments = [];
  List<Map<String, dynamic>> cardUpiPayments = [];
  List<Map<String, dynamic>> nonChargeableOrders = [];
  // Method to place the order and store it in SharedPreferences
  Future<void> placeOrder(String paymentMode, double amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderDetails = 'Order placed with $paymentMode, Amount: $amount';

    // Store order details in SharedPreferences
    await prefs.setString('lastOrder', orderDetails);

    // Show success message
    log('Order placed successfully!');
  }

  Future<void> storeBillData({
    required String billNumber,
    required String billDate,
    required String selectedCustomerName,
    required String selectedCustomerCode,
    required double totalAmount,
    required List<Map<String, dynamic>> items, // New parameter
    required Map<String, double> quantities, // New parameter
    required Map<String, double> rates, // New parameter
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing customer bills or initialize a new list if none exist
    List<String>? customerBills =
        prefs.getStringList('${selectedCustomerCode}_bills');

    // Create a map to represent the new bill
    Map<String, dynamic> newBill = {
      'customerCode': selectedCustomerCode,
      'billNumber': billNumber,
      'billDate': billDate,
      'customerName': selectedCustomerName,
      'totalAmount': totalAmount.toString(),
      'items': items, // Add items to the bill
      'quantities': quantities, // Add quantities to the bill
      'rates': rates, // Add rates to the bill
    };

    // Convert the map to a JSON string for storage
    String newBillJson = jsonEncode(newBill);

    // Append new bill to customer bills list or create a new list if it doesn't exist
    if (customerBills != null) {
      customerBills.add(newBillJson);
    } else {
      customerBills = [newBillJson];
    }

    // Store the updated list of bills for the customer
    await prefs.setStringList('${selectedCustomerCode}_bills', customerBills);

    // Retrieve the customer names map (stored as JSON) from SharedPreferences
    String? customerNamesJson = prefs.getString('customer_names');
    Map<String, String> customerNames = customerNamesJson != null
        ? Map<String, String>.from(jsonDecode(customerNamesJson))
        : {};

    // Update the map with the new customer name
    customerNames[selectedCustomerCode] = selectedCustomerName;

    // Save the updated customer names map back to SharedPreferences as JSON
    await prefs.setString('customer_names', jsonEncode(customerNames));

    // Log the updated customer names map
    debugPrint('Updated customer names stored: $customerNames');

    notifyListeners();
  }

  Future<void> storePaymentData({
    required String paymentId,
    required String paymentDate,
    required String selectedCustomerName,
    required String selectedCustomerCode,
    required String paymentMode,
    required String enteredAmount,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing payments for the customer or initialize a new list
    List<String>? customerPayments =
        prefs.getStringList('${selectedCustomerCode}_payments');

    // Create a map to represent the new payment
    Map<String, dynamic> newPayment = {
      'customerCode': selectedCustomerCode,
      'paymentId': paymentId,
      'paymentDate': paymentDate,
      'customerName': selectedCustomerName,
      'paymentMode': paymentMode,
      'enteredAmount': enteredAmount,
    };

    // Convert the map to a JSON string for storage
    String newPaymentJson = jsonEncode(newPayment);

    log('New Payment JSON: $newPaymentJson');

    // If the customer already has payments, append the new payment to the list
    if (customerPayments != null) {
      customerPayments.add(newPaymentJson);
    } else {
      customerPayments = [newPaymentJson];
    }

    // Store the updated list of payments for the customer
    await prefs.setStringList(
        '${selectedCustomerCode}_payments', customerPayments);

    List<String>? customerCodes = prefs.getStringList('customer_codes');
    if (customerCodes == null) {
      customerCodes = [selectedCustomerCode];
    } else if (!customerCodes.contains(selectedCustomerCode)) {
      customerCodes.add(selectedCustomerCode);
    }
    await prefs.setStringList('customer_codes', customerCodes);

    // Log the updated list of bills and customer codes
    log('Updated Payment List for $selectedCustomerCode: $customerPayments');
    log('Updated Customer Codes List: $customerCodes');

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> loadBillData(String customerCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch the list of bills for this specific customer
    List<String>? customerBills = prefs.getStringList('${customerCode}_bills');

    if (customerBills == null) {
      return [];
    }

    List<Map<String, dynamic>> bills = customerBills.map((billJson) {
      Map<String, dynamic> bill = jsonDecode(billJson);

      double totalAmount = double.tryParse(bill['totalAmount'] ?? '0.0') ?? 0.0;

      return {
        'billNumber': bill['billNumber'] ?? '',
        'billDate': bill['billDate'] ?? '',
        'customerName': bill['customerName'] ?? '',
        'customerCode': bill['customerCode'] ?? '',
        'totalAmount': totalAmount,
        'items': bill['items'] ?? [], // Ensure this is a list
        'quantities': bill['quantities'] ?? {}, // Load quantities
        'rates': bill['rates'] ?? {}, // Load rates
      };
    }).toList();

    return bills;
  }

  Future<List<Map<String, dynamic>>> loadAllBillData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve all customer codes
    List<String>? customerCodes = prefs.getStringList('customer_codes');
    log('Retrieved Customer Codes: $customerCodes');

    if (customerCodes == null) {
      log('No customer codes found.');
      return [];
    }

    List<Map<String, dynamic>> billDataList = [];

    for (String code in customerCodes) {
      // Retrieve the bills for each customer
      List<String>? customerBills = prefs.getStringList('${code}_bills');
      log('Retrieved Bills for $code: $customerBills');

      if (customerBills != null) {
        for (String billJson in customerBills) {
          try {
            Map<String, dynamic> billData = jsonDecode(billJson);
            log('Decoded Bill Data: $billData');
            billDataList.add(billData);
          } catch (e) {
            log('Error decoding bill JSON: $e');
          }
        }
      }
    }

    log('All Bill Data Loaded: $billDataList');
    return billDataList;
  }

  Future<List<Map<String, dynamic>>> loadAllPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve all customer codes
    List<String>? customerCodes = prefs.getStringList('customer_codes');
    log('Retrieved Customer Codes: $customerCodes');

    if (customerCodes == null) {
      log('No customer codes found.');
      return [];
    }

    List<Map<String, dynamic>> paymentDataList = [];

    for (String code in customerCodes) {
      // Retrieve the payments for each customer
      List<String>? customerPayments = prefs.getStringList('${code}_payments');
      log('Retrieved Payments for $code: $customerPayments');

      if (customerPayments != null) {
        for (String paymentJson in customerPayments) {
          try {
            Map<String, dynamic> paymentData = jsonDecode(paymentJson);
            log('Decoded Payment Data: $paymentData');
            paymentDataList.add(paymentData);
          } catch (e) {
            log('Error decoding payment JSON: $e');
          }
        }
      }
    }

    log('All Payment Data Loaded: $paymentDataList');
    return paymentDataList;
  }

  Future<List<Map<String, dynamic>>> loadPaymentData(
      String selectedCustomerCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the list of payments for the specific customer
    List<String>? customerPayments =
        prefs.getStringList('${selectedCustomerCode}_payments');

    if (customerPayments == null) {
      // If no payments are found, return an empty list
      return [];
    }

    // Decode the list of JSON strings into a list of payment maps
    List<Map<String, dynamic>> payments = customerPayments.map((paymentJson) {
      Map<String, dynamic> payment = jsonDecode(paymentJson);

      // Ensure enteredAmount is parsed as double
      double enteredAmount =
          double.tryParse(payment['enteredAmount'] ?? '0.0') ?? 0.0;

      return {
        'paymentId': payment['paymentId'] ?? '',
        'paymentDate': payment['paymentDate'] ?? '',
        'customerName': payment['customerName'] ?? '',
        'customerCode': selectedCustomerCode,
        'paymentMode': payment['paymentMode'] ?? '',
        'enteredAmount': enteredAmount,
      };
    }).toList();

    return payments;
  }

  Future<void> storeCashPaymentData(
    String customerName,
    String customerCode,
    double totalAmount,
    double receivedAmount,
    double returnAmount,
    int billNumber,
    String? selectedPaymentMode,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Create a payment map
    Map<String, dynamic> paymentData = {
      'billNumber': billNumber,
      'customerName': customerName,
      'customerCode': customerCode,
      'totalAmount': totalAmount,
      'receivedAmount': receivedAmount,
      'returnAmount': returnAmount,
      'selectedPaymentMode': selectedPaymentMode,
    };

    // Retrieve existing payments
    List<String>? existingPayments = prefs.getStringList('cashPayments') ?? [];

    // Add the new payment to the list
    existingPayments.add(json.encode(paymentData));

    // Store the updated list back to SharedPreferences
    await prefs.setStringList('cashPayments', existingPayments);
  }

  // Function to load cash payments from SharedPreferences
  Future<List<Map<String, dynamic>>> loadCashPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedPayments = prefs.getStringList('cashPayments');

    if (storedPayments != null) {
      _cashPayments = storedPayments
          .map((payment) => json.decode(payment) as Map<String, dynamic>)
          .toList();
    }

    return _cashPayments;
  }

  Future<void> storeCardUpiPayment(double totalAmount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current bill number and increment it
    int currentBillNumber = await getCurrentBillNumber();
    int newBillNumber = currentBillNumber + 1;

    // Prepare the payment data
    Map<String, dynamic> paymentData = {
      'billNumber': newBillNumber,
      'totalAmount': totalAmount,
    };

    // Store the payment data as a JSON string in SharedPreferences
    List<String>? storedPayments = prefs.getStringList('cardUpiPayments') ?? [];
    storedPayments.add(json.encode(paymentData));
    await prefs.setStringList('cardUpiPayments', storedPayments);

    // Update the bill number for the next transaction
    await setCurrentBillNumber(newBillNumber);
  }

  Future<List<Map<String, dynamic>>> loadCardUpiPayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedPayments = prefs.getStringList('cardUpiPayments');

    List<Map<String, dynamic>> cardUpiPayments = [];

    if (storedPayments != null) {
      cardUpiPayments = storedPayments
          .map((payment) => json.decode(payment) as Map<String, dynamic>)
          .toList();
    }

    return cardUpiPayments;
  }

  Future<void> storeCreditPartyData(
      String selectedCustomerName,
      String selectedCustomerCode,
      double totalAmount,
      String enteredAmount,
      String selectedPaymentMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store the data in SharedPreferences
    await prefs.setString('creditPartyCustomerName', selectedCustomerName);
    await prefs.setString('creditPartyCustomerCode', selectedCustomerCode);
    await prefs.setDouble('creditPartyTotalAmount', totalAmount);
    await prefs.setString('creditPartyEnteredAmount', enteredAmount);
    await prefs.setString('creditPartyPaymentMode', selectedPaymentMode);

    // Optionally notify listeners or perform additional actions
    notifyListeners();
  }

  Future<Map<String, dynamic>> loadCreditPartyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data from SharedPreferences
    String? customerName = prefs.getString('creditPartyCustomerName');
    String? customerCode = prefs.getString('creditPartyCustomerCode');
    double? totalAmount = prefs.getDouble('creditPartyTotalAmount');
    String? enteredAmount = prefs.getString('creditPartyEnteredAmount');
    String? paymentMode = prefs.getString('creditPartyPaymentMode');

    return {
      'customerName': customerName ?? '',
      'customerCode': customerCode ?? '',
      'totalAmount': totalAmount ?? 0.0,
      'enteredAmount': enteredAmount ?? '',
      'paymentMode': paymentMode ?? '',
    };
  }

  Future<void> storeNonChargeableOrder({
    required String note,
    required String personName,
    required double totalAmount,
    required int billNumber,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Create a map to represent the non-chargeable order
    Map<String, dynamic> nonChargeableOrder = {
      'billNumber': billNumber,
      'note': note,
      'personName': personName,
      'totalAmount': totalAmount,
    };

    // Convert the map to a JSON string for storage
    String nonChargeableOrderJson = jsonEncode(nonChargeableOrder);

    // Retrieve existing non-chargeable orders
    List<String>? existingOrders =
        prefs.getStringList('nonChargeableOrders') ?? [];

    // Add the new order to the list
    existingOrders.add(nonChargeableOrderJson);

    // Store the updated list back to SharedPreferences
    await prefs.setStringList('nonChargeableOrders', existingOrders);
  }

  Future<List<Map<String, dynamic>>> loadNonChargeableOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the stored non-chargeable orders
    List<String>? storedOrders = prefs.getStringList('nonChargeableOrders');

    // Parse the stored JSON strings into a list of maps

    if (storedOrders != null) {
      for (String order in storedOrders) {
        nonChargeableOrders.add(Map<String, dynamic>.from(jsonDecode(order)));
      }
    }

    return nonChargeableOrders; // Return the list of non-chargeable orders
  }

  Future<void> savedispatchdataWithBillNumber({
    required double totalAmount,
    required String orderDate,
    required String paymentUsed,
    required String customerCode,
    required String customerName,
  }) async {
    // Get current bill number from customer credit provider
    int billNumber = await getCurrentBillNumber();

    // Save the dispatch data using the shared preferences
    await savedispatchdata(
      billNumber: billNumber,
      totalAmount: totalAmount,
      orderDate: orderDate,
      paymentUsed: paymentUsed,
      customerCode: customerCode,
      customerName: customerName,
    );

    // Increment and store the next bill number
    await setCurrentBillNumber(billNumber + 1);
  }

  Future<void> savedispatchdata({
    required int billNumber,
    required double totalAmount,
    required String orderDate,
    required String paymentUsed,
    required String customerCode,
    required String customerName,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('billNumber', billNumber);
    await prefs.setDouble('totalAmount', totalAmount);
    await prefs.setString('orderDate', orderDate);
    await prefs.setString('paymentUsed', paymentUsed);
    await prefs.setString('customerCode', customerCode);
    await prefs.setString('customerName', customerName);
  }

  Future<void> setCurrentBillNumber(int number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentBillNumber', number);
  }

  // Function to get current bill number
  Future<int> getCurrentBillNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentBillNumber') ?? 0;
  }

  // Function to store payment ID
  Future<void> setCurrentPaymentId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPaymentId', id);
  }

  // Function to get current payment ID
  Future<int> getCurrentPaymentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentPaymentId') ?? 0;
  }
}
