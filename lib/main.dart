import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

import 'user_key_helper.dart';
import 'api_client.dart';
import 'daily_riddle_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riddle Me This!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  TextEditingController _userIdController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkUserKey();
  }

  _checkUserKey() async {
    String? userKey = await UserKeyHelper.getUserKey();
    if (userKey != null) {
      _navigateToDailyRiddlePage(userKey);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToDailyRiddlePage(String userKey) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DailyRiddlePage(userId: userKey),
      ),
    );
  }

  _connectExistingAccount() async {
    setState(() {
      _loading = true;
    });
    try {
      String userKey = _userIdController.text.trim();
      ApiClient apiClient = ApiClient();
      bool success =
          await apiClient.updateUserDeviceInfo(userKey, await _getDeviceInfo());
      if (success) {
        await UserKeyHelper.setUserKey(userKey);
        _navigateToDailyRiddlePage(userKey);
      } else {
        _showErrorDialog('Could not connect your account. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Sorry, there was an error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  _createUser() async {
    setState(() {
      _loading = true;
    });
    try {
      ApiClient apiClient = ApiClient();
      String? uuid = await apiClient.createUser(await _getDeviceInfo());
      if (uuid != null) {
        await UserKeyHelper.setUserKey(uuid);
        _navigateToDailyRiddlePage(uuid);
      }
    } catch (e) {
      _showErrorDialog('Sorry, there was an error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = _readAndroidBuildData(androidInfo);
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = _readIosDeviceInfo(iosInfo);
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }

    return deviceData;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return {
      'version.sdk_int': build.version.sdkInt,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'device': build.device,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return {
      'name': data.name,
      'system_name': data.systemName,
      'system_version': data.systemVersion,
      'model': data.model,
      'localized_model': data.localizedModel,
      'identifier_for_vendor': data.identifierForVendor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riddle Me This!'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '🎉 Welcome to Riddle Me This! 🥳',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _createUser,
                child: _loading
                    ? CircularProgressIndicator()
                    : Text('Create New Account'),
              ),
              SizedBox(height: 24),
              Text('Or connect an existing account'),
              SizedBox(height: 16),
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'Existing User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _connectExistingAccount,
                child: Text('Connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
