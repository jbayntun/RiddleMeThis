import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _apiBaseUrl = 'http://localhost:8000';

  Future<String?> createUser(Map<String, dynamic> deviceInfo) async {
    final String createUserUrl = '$_apiBaseUrl/create_user/';

    final response = await http.post(
      Uri.parse(createUserUrl),
      body: json.encode({'device_info': deviceInfo}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return json.decode(response.body)['uuid'];
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<bool> updateUserDeviceInfo(
      String userUuid, Map<String, dynamic> deviceInfo) async {
    final String userProfilesUrl = '/api/user_profiles/';
    final response = await http.patch(
      Uri.parse(_apiBaseUrl + userProfilesUrl + userUuid + '/'),
      body: json.encode({'device_info': deviceInfo}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error updating user device info: ${response.body}');
      return false;
    }
  }
}
