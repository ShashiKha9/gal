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
