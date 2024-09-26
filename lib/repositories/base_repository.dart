// TODO: Remove this line after Login API is updated
// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// import 'package:galaxy_mini/utils/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/api_urls.dart';

class BaseRepository {
  // Static values for headers
  final String accessToken = "a87ff679a2f3e71d9181a67b7542122c84";
  final String userId = "4";

  // For POST request
  Future<http.Response> postHttp({
    required Map<String, dynamic> data,
    required String api,
    bool useToken = false,
  }) async {
    log(api, name: 'postHttp');
    log(data.toString(), name: 'postHttp');

    // TODO: Uncomment this code & remove Existing headers after Login API is updated
    // String? accessToken;
    // String? userId;

    // if (useToken) {
    //   accessToken =
    //       await MySharedPreferences.instance.getStringValue("authToken");
    //   userId = await MySharedPreferences.instance.getStringValue("userId");
    //   log(accessToken.toString(), name: "authToken");
    //   log(userId.toString(), name: "userId");
    // }
    // final headers = {
    //   'Content-Type': 'application/json',
    //   if (accessToken != null) 'Authorization': accessToken,
    //   if (userId != null) 'UserId': userId,
    // };

    // Set up the headers
    final headers = {
      'Content-Type': 'application/json',
      'access-token': accessToken,
      'user-id': userId,
    };

    return http.post(
      Uri.parse(ApiUrls.baseUrl + api),
      headers: headers,
      body: json.encode(data),
    );
  }

  // For GET request
  Future<http.Response> getHttp({
    required String api,
    bool useToken = false,
  }) async {
    log(api, name: 'getHttp');
    log(Uri.parse(ApiUrls.baseUrl + api).toString(), name: 'getHttp');

    // TODO: Uncomment this code & remove Existing headers after Login API is updated
    // String? accessToken;
    // String? userId;

    // if (useToken) {
    //   accessToken =
    //       await MySharedPreferences.instance.getStringValue("authToken");
    //   userId = await MySharedPreferences.instance.getStringValue("userId");
    //   log(accessToken.toString(), name: "authToken");
    //   log(userId.toString(), name: "userId");
    // }
    // final headers = {
    //   'Content-Type': 'application/json',
    //   if (accessToken != null) 'Authorization': accessToken,
    //   if (userId != null) 'UserId': userId,
    // };

    // Set up the headers
    final headers = {
      'Content-Type': 'application/json',
      'access-token': accessToken,
      'user-id': userId,
    };

    return http.get(
      Uri.parse(ApiUrls.baseUrl + api),
      headers: headers,
    );
  }
}
