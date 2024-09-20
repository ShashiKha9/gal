import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerCreditProvider extends ChangeNotifier {
  static const _billNumberKey = 'billNumber';
  static const _paymentIdKey = 'paymentId';
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
    };

    // Convert the map to a JSON string for storage
    String newBillJson = jsonEncode(newBill);

    // Log the new bill JSON
    log('New Bill JSON: $newBillJson');

    // If the customer already has bills, append the new bill to the list
    if (customerBills != null) {
      customerBills.add(newBillJson);
    } else {
      customerBills = [newBillJson];
    }

    // Store the updated list of bills for the customer
    await prefs.setStringList('${selectedCustomerCode}_bills', customerBills);

    // Store or update the list of customer codes
    List<String>? customerCodes = prefs.getStringList('customer_codes');
    if (customerCodes == null) {
      customerCodes = [selectedCustomerCode];
    } else if (!customerCodes.contains(selectedCustomerCode)) {
      customerCodes.add(selectedCustomerCode);
    }
    await prefs.setStringList('customer_codes', customerCodes);

    // Log the updated list of bills and customer codes
    log('Updated Bills List for $selectedCustomerCode: $customerBills');
    log('Updated Customer Codes List: $customerCodes');

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

  // Method to store cash payment data
  Future<void> storeCashPaymentData(
    String selectedCustomerName,
    String selectedCustomerCode,
    double totalAmount,
    double receivedAmount,
    double returnAmount,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store customer and cash payment data in SharedPreferences
    await prefs.setString('cashPaymentCustomerName', selectedCustomerName);
    await prefs.setString('cashPaymentCustomerCode', selectedCustomerCode);
    await prefs.setDouble('cashPaymentTotalAmount', totalAmount);
    await prefs.setDouble('cashReceivedAmount', receivedAmount);
    await prefs.setDouble('cashReturnAmount', returnAmount);

    // Notify listeners to reflect changes
    notifyListeners();
  }

// Method to load cash payment data
  Future<Map<String, dynamic>> loadCashPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve cash payment data from SharedPreferences
    double receivedAmount = prefs.getDouble('cashReceivedAmount') ?? 0.0;
    double returnAmount = prefs.getDouble('cashReturnAmount') ?? 0.0;

    return {
      'receivedAmount': receivedAmount,
      'returnAmount': returnAmount,
    };
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
