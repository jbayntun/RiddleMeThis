import 'dart:convert';
import 'package:http/http.dart' as http;

import 'daily_riddle.dart';
import 'user_key_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static const String _apiBaseUrl = 'http://localhost:8000';

  static final String _appToken = dotenv.env['RIDDLE_API_SECRET'] ?? '';

  // Create a static header value
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'App-Token': _appToken,
  };

  Future<String?> createUser(Map<String, dynamic> deviceInfo) async {
    final String createUserUrl = '$_apiBaseUrl/create_user/';

    final response = await http.post(
      Uri.parse(createUserUrl),
      body: json.encode({'device_info': deviceInfo}),
      headers: _headers,
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
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error updating user device info: ${response.body}');
      return false;
    }
  }

  Future<DailyRiddle> getDailyRiddle(String userId) async {
    final String dailyRiddleUrl = '$_apiBaseUrl/api/daily_riddle/$userId/';

    final response = await http.get(
      Uri.parse(dailyRiddleUrl),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return DailyRiddle.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load daily riddle: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> attemptRiddle({
    required int riddleId,
    required int numberOfGuesses,
    required int numberOfHintsUsed,
    required int timeTaken,
    required String status,
  }) async {
    final String url = '$_apiBaseUrl/api/riddle_attempts/';

    final String? userId = await UserKeyHelper.getUserKey();
    if (userId == null) {
      print('Error: User ID not found');
      return null;
    }

    final Map<String, dynamic> data = {
      'user': userId,
      'riddle': riddleId,
      'number_of_guesses': numberOfGuesses,
      'number_of_hints_used': numberOfHintsUsed,
      'time_taken': timeTaken,
      'status': status,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      print('RiddleAttempt created successfully!');
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode} ${response.body}');
      return null;
    }
  }
}
