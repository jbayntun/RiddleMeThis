// utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared_prefereces_helper.dart';
import 'package:daily_riddle_app/daily_riddle.dart';
import 'api_client.dart';

class ModalUtils {
  static Future<void> _copyUserIdToClipboard(BuildContext context) async {
    String? userId = await SharedPreferencesHelper.getUserKey();
    if (userId != null) {
      await Clipboard.setData(ClipboardData(text: userId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get User ID')),
      );
    }
  }

  static void showUserIdModal(BuildContext context) async {
    String? userId = await SharedPreferencesHelper.getUserKey();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User ID',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                userId ?? 'Failed to get User ID',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _copyUserIdToClipboard(context),
                child: Text('Copy to Clipboard'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<DailyRiddle?> getNewRiddleIfDifferent(
      ApiClient apiClient, String userId, DailyRiddle currentRiddle) async {
    try {
      DailyRiddle newRiddle = await apiClient.getDailyRiddle(userId);

      // Compare the IDs of the new riddle and the current riddle.
      if (newRiddle.id == currentRiddle.id) {
        return null;
      } else {
        return newRiddle;
      }
    } catch (e) {
      print('Error getting new riddle: $e');
      return null;
    }
  }
}
