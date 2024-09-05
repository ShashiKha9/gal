import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:galaxy_mini/utils/api_urls.dart';
import 'package:galaxy_mini/repositories/base_repository.dart';

class AuthRepository extends BaseRepository {
  Future login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await postHttp(
        data: {
          "username": username,
          "password": password,
          "macaddress": '02:00:00:00:00:00',
          "deviceid": 'dummy-deviceid',
          "subscriberid": 'dummy-subscriberid',
          'timestamp': DateTime.now().toIso8601String(),
        },
        api: ApiUrls.login,
      );
      if (response.statusCode == 200) {
        log(response.body, name: 'loginApi');

        return json.decode(response.body);
      } else {
        log(response.body, name: 'error response login');
        return json.decode(response.body);
      }
    } on SocketException catch (e) {
      log(e.toString());
      return {'message': e};
    }
  }
}

//   Future<Map<String, dynamic>> login({
//     required String username,
//     required String password,
//     String macAddress = '02:00:00:00:00:00',
//     String deviceId = 'dummy-deviceid',
//     String subscriberId = 'dummy-subscriberid',
//   }) async {
//     if (username.isEmpty || password.isEmpty) {
//       throw Exception('Please enter both username and password');
//     }
//
//     final url = Uri.parse(baseUrl);
//
//     try {
//       final response = await http.post(
//         url,
//         // headers: {
//         //   'access-token': accessToken,
//         //   'user-id': userId,
//         // },
//         body: {
//           'username': username,
//           'password': password,
//           'macaddress': macAddress,
//           'deviceid': deviceId,
//           'subscriberid': subscriberId,
//           'timestamp': DateTime.now().toIso8601String(),
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status_code'] == "200") {
//           return responseData;
//         } else {
//           throw Exception('Login failed: ${responseData['msg']}');
//         }
//       } else {
//         throw Exception('Error: ${response.reasonPhrase}');
//       }
//     } catch (error) {
//       throw Exception('An error occurred. Please try again later.');
//     }
//   }
// }
