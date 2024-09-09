import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:galaxy_mini/components/scaffold_message.dart';
import 'package:galaxy_mini/repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier{

  final custRepo = CustomerRepository();
  
  Future<bool> addCustomer({
    required String name,
    required String email,
    required String mobile1,
    required String mobile2,
    required String landline,
    required String address,
    required String birthdate,
    required String gstNo,
    required String note,
    required bool isActive,
    required bool isPremium,
    required String customerCode,
    required int createdBy,
  }) async {
    try {
      Map<String, dynamic> data = {
  "name": name,
  "email": email,
  "mobile1": mobile1,
  "mobile2": mobile2,
  "landline": landline,
  "address": address,
  "birthdate": birthdate,
  "gstNo": gstNo,
  "note": note,
  "isActive": isActive,
  "isPremium": isPremium,
  "customerCode": customerCode,
  "createdBy": createdBy
};
      final response = await custRepo.postCustomer(data: data);
      log(response.toString(), name: 'postCustomer');
      Fluttertoast.showToast(msg: response['message']);
      scaffoldMessage(message: response['message']);
      return response['data'] == 200;
    } on SocketException catch (e) {
      scaffoldMessage(message: '$e');
    } catch (e, s) {
      log(e.toString(), name: 'error postCustomer', stackTrace: s);
    }
    return false;
  }
}