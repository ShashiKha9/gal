import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String userId = '10';
  final String accessToken = 'd3d9446802a44259755d38e6d163e82098';

  Future<List<String>> fetchDepartments() async {
    final url = Uri.parse('https://test17042024.galaxymini.in/mobileapi/api/getDepartment');
    final response = await http.get(
      url,
      headers: {
        'user-id': userId,
        'access-token': accessToken,
      },
    );

    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      if (responseData.containsKey('body') && responseData['body'] is List) {
        final List<dynamic> body = responseData['body'];
        return body.map((item) => item['description'].toString()).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: ${responseData['msg']}');
    } else {
      throw Exception('Failed to load departments');
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final url = Uri.parse('https://test17042024.galaxymini.in/mobileapi/api/getItem');
    final response = await http.get(
      url,
      headers: {
        'user-id': userId,
        'access-token': accessToken,
      },
    );

    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      if (responseData.containsKey('body') && responseData['body'] is List) {
        final List<dynamic> body = responseData['body'];
        return body.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: ${responseData['msg']}');
    } else {
      throw Exception('Failed to load items');
    }
  }
}
