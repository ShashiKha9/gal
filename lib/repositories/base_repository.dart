import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
    log(Uri.parse(ApiUrls.baseUrl + api).toString(), name: 'getHttp');

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
