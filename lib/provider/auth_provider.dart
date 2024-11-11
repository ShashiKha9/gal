import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/scaffold_message.dart';
import '../repositories/auth_repository.dart';

class LoginProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  Future<bool> userLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response =
          await _authRepository.login(username: username, password: password);
      log(response.toString(), name: 'response userLogin');
      scaffoldMessage(message: response['message']);
      return response['code'] == 200;
    } on SocketException catch (e) {
      scaffoldMessage(message: e.toString());
    } catch (e) {
      log(e.toString(), name: 'error userLogin');
    }
    return false;
  }

  Future<bool> changePassword(
      {required String oldPassword,
      required String newPassword,
      required String userId}) async {
    try {
      final response = await _authRepository.changePassword(
          oldPassword: oldPassword, newPassword: newPassword, userId: userId);
      log(response.toString(), name: 'response changePassword');
      scaffoldMessage(message: response['msg']);
      return response['status_code'] == 200;
    } on SocketException catch (e) {
      scaffoldMessage(message: e.toString());
    } catch (e) {
      log(e.toString(), name: 'error changePassword');
    }
    return false;
  }

  Future<bool> changeUser(
      {required String username,
      required String password,
      required String userType,
      required String userId}) async {
    try {
      final response = await _authRepository.changeUser(
          username: username,
          password: password,
          userId: userId,
          userType: userType);
      log(response.toString(), name: 'response change user');
      scaffoldMessage(message: response['msg']);
      return response['status_code'] == 200;
    } on SocketException catch (e) {
      scaffoldMessage(message: e.toString());
    } catch (e) {
      log(e.toString(), name: 'error changeUser');
    }
    return false;
  }

  // bool _isLoading = false;
  // String? _errorMessage;
  //
  // bool get isLoading => _isLoading;
  // String? get errorMessage => _errorMessage;
  //
  // Future<void> login(String username, String password) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final responseData = await _authRepository.login(
  //       username: username,
  //       password: password,
  //     );
  //
  //     _isLoading = false;
  //     notifyListeners();
  //     // Handle successful login, e.g., navigate to the home screen or save user info.
  //   } catch (error) {
  //     _isLoading = false;
  //     _errorMessage = error.toString();
  //     notifyListeners();
  //   }
  // }
}
