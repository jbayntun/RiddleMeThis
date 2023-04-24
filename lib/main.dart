import 'package:flutter/material.dart';
import 'dart:math';

import 'package:share/share.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'user_key_helper.dart';
import 'mock_api.dart'; // TODO temporary
import 'api_client.dart';

void main() {
  runApp(DailyRiddleApp());
}

class DailyRiddleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riddle Me This!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RiddlePage(),
    );
  }
}

class RiddlePage extends StatefulWidget {
  @override
  _RiddlePageState createState() => _RiddlePageState();
}

class _RiddlePageState extends State<RiddlePage> {
  String riddle = '';
  int attempts = 0;
  int hintsUsed = 0;
  bool isSolved = false;
  bool isLoading = true;
  Duration elapsedTime = Duration();
  late DateTime startTime;
  String correctAnswer = '';
  TextEditingController answerController = TextEditingController();
  String? currentOneLiner;
  String? _userKey;

  List<Hint> hints = [];

  @override
  void initState() {
    super.initState();

    // Check for user key
    UserKeyHelper.getUserKey().then((userKey) {
      if (userKey == null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          showUserKeyCheckModal(context);
        });
      }
    });

    isLoading = true;
    currentOneLiner = getRandomOneLiner();

    fetchRiddle().then((data) {
      setState(() {
        riddle = data['riddle'];
        correctAnswer = data['correctAnswer'];
        hints = (data['hints'] as List<dynamic>)
            .map((hint) => Hint(
                  description: hint['description'],
                  content: hint['content'],
                ))
            .toList();
        isLoading = false;
        startTime = DateTime.now(); // Set startTime here
      });
    });
  }

  void onHintRevealed() {
    setState(() {
      hintsUsed++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riddle Me This!'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Riddle section
            Container(
              height: MediaQuery.of(context).size.height * 3 / 8,
              padding: EdgeInsets.all(16),
              child: Center(
                child: isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            currentOneLiner ?? '',
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Text(
                        riddle,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            // User input section
            Container(
              height: 48, // Set the desired height of the TextField
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: answerController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your answer',
                ),
              ),
            ),
// Solve button section
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48, // Set the same height as the TextField's container
                child: ElevatedButton(
                  onPressed: () {
                    if (answerController.text.trim().isNotEmpty) {
                      if (answerController.text.trim().toLowerCase() ==
                          correctAnswer.toLowerCase()) {
                        // correct solution!
                        setState(() {
                          isSolved = true;
                          elapsedTime = DateTime.now().difference(startTime);
                        });
                        showCelebratoryModal(context);
                      } else {
                        // incorrect answer, but more attempts left
                        setState(() {
                          attempts++;
                        });
                        if (attempts >= 3) {
                          // all attempts used, incorrect answer
                          setState(() {
                            isSolved = true;
                            elapsedTime = DateTime.now().difference(startTime);
                          });
                        }
                        showSadModal(
                          context,
                          reachedMaxAttempts: attempts == 3,
                          onClose: () => answerController.clear(),
                          correctAnswer: correctAnswer,
                        );
                      }
                    }
                  },
                  child: Text('Solve'),
                ),
              ),
            ),

// Statistics section
            Container(
              margin: EdgeInsets.all(16),
              //padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left column: Guesses
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Guesses',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10), // Add margin below the title
                        Text('$attempts/3'),
                      ],
                    ),
                  ),
                  // Middle column: Time
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Time Used',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10), // Add margin below the title
                        StreamBuilder(
                          stream: Stream.periodic(Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            return Text(
                              isLoading
                                  ? '' // Show empty string while loading
                                  : isSolved
                                      ? '${elapsedTime.inHours.toString().padLeft(2, '0')}:${elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                                      : '${DateTime.now().difference(startTime).inHours.toString().padLeft(2, '0')}:${DateTime.now().difference(startTime).inMinutes.remainder(60).toString().padLeft(2, '0')}:${DateTime.now().difference(startTime).inSeconds.remainder(60).toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 16),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Right column: Hints
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hints',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10), // Add margin below the title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Hints: $hintsUsed/${hints.length}"),
                            ElevatedButton(
                              onPressed: () =>
                                  showHintsModal(context, onHintRevealed),
                              child: Text('Hints'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCelebratoryModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulations! 🎉🥳"),
          content: Text("You've solved the riddle!"),
          actions: [
            TextButton(
              onPressed: () {
                String shareText = 'I solved the daily riddle!\n\n'
                    '• Guesses: $attempts/3\n'
                    '• Time: ${DateTime.now().difference(startTime).inHours}:${DateTime.now().difference(startTime).inMinutes.remainder(60)}:${DateTime.now().difference(startTime).inSeconds.remainder(60)}\n'
                    '• Hints used: $hintsUsed/3';

                Share.share(shareText);
              },
              child: Text("Share"),
            ),
          ],
        );
      },
    );
  }

  void showSadModal(BuildContext context,
      {required bool reachedMaxAttempts,
      required VoidCallback onClose,
      String? correctAnswer}) {
    showDialog(
      context: context,
      barrierDismissible: !reachedMaxAttempts,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reachedMaxAttempts
              ? "😢 All Attempts Used"
              : "😔 Incorrect Answer"),
          content: Text(reachedMaxAttempts
              ? "Sorry, try again tomorrow.\nThe correct answer is ${correctAnswer![0].toUpperCase()}${correctAnswer.substring(1)}."
              : "Sorry, try again."),
          actions: reachedMaxAttempts
              ? []
              : [
                  TextButton(
                    onPressed: () {
                      onClose();
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"),
                  ),
                ],
        );
      },
    );
  }

  void showHintsModal(BuildContext context, VoidCallback onHintRevealed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Hints"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: hints.map((hint) {
                  int hintIndex = hints.indexOf(hint);
                  bool hintUsed = hintIndex < hintsUsed;
                  return ListTile(
                    title: Text(hint.description),
                    trailing: InkWell(
                      onTap: () {
                        if (!hint.isRevealed) {
                          setState(() {
                            hint.isRevealed = true;
                          });
                          onHintRevealed();
                        }
                      },
                      child: Container(
                        width: 100, // Increase width to accommodate text
                        height: 20,
                        color: hintUsed ? Colors.transparent : Colors.black,
                        alignment: Alignment.center,
                        child: Text(
                          hintUsed
                              ? hint.content
                              : "Tap to reveal", // Show "Tap to reveal" text when the hint is not used
                          style: TextStyle(
                              color: hintUsed ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showUserKeyCheckModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController userIdController = TextEditingController();
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Welcome to Riddle Me This!'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userKey != null)
                      Text('User Key: $_userKey'), // Display the user key
                    Text('Please choose an option:'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Handle new account creation
                        await onNewAccountPressed();
                      },
                      child: Text('Create a New Account'),
                    ),
                    SizedBox(height: 16),
                    Text('Or connect an existing account:'),
                    SizedBox(height: 8),
                    TextField(
                      controller: userIdController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your user_id',
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            String? userInputUuid =
                                userIdController.text.trim();
                            if (userInputUuid.isNotEmpty) {
                              // Get device info
                              Map<String, dynamic> deviceInfo =
                                  await getDeviceInfo();

                              // Call the API to update the user's device info
                              bool isSuccessful = await ApiClient()
                                  .updateUserDeviceInfo(
                                      userInputUuid, deviceInfo);

                              if (isSuccessful) {
                                // Save the user key to the device
                                await UserKeyHelper.setUserKey(userInputUuid);

                                // Update the UI to show the user key
                                setState(() {
                                  _userKey = userInputUuid;
                                });

                                // Close the modal
                                Navigator.of(context).pop();
                              } else {
                                // Show a message that the provided user ID is not valid
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Invalid User ID. Please try again.')),
                                );
                              }
                            } else {
                              // Show a message that the user ID field is empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Please enter a User ID.')),
                              );
                            }
                          },
                          child: Text('Connect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getRandomOneLiner() {
    List<String> oneLiners = [
      "I'm working at the speed of light, but it still takes time!",
      "Good things come to those who wait... just a moment longer!",
      "I'd tell a joke while you wait, but I'm too busy loading!",
      "Just like a watched pot never boils, watching me won't make me load faster!",
    ];

    return oneLiners[Random().nextInt(oneLiners.length)];
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'os': 'Android',
          'os_version': androidInfo.version.release,
          'device_model': androidInfo.model,
        };
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'os': 'iOS',
          'os_version': iosInfo.systemVersion,
          'device_model': iosInfo.utsname.machine,
        };
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }

    return deviceData;
  }

  Future<void> onNewAccountPressed() async {
    try {
      // Get device info
      Map<String, dynamic> deviceInfo = await getDeviceInfo();

      // Hardcoded device info
      // Map<String, dynamic> deviceInfo = {
      //   'os': 'Android',
      //   'os_version': '10.0',
      //   'device_model': 'Pixel 4a',
      // };

      // Call the API to create a new user
      String? newUserKey = await ApiClient().createUser(deviceInfo);

      if (newUserKey != null) {
        // Save the user key to the device
        await UserKeyHelper.setUserKey(newUserKey);

        // Update the UI to show the user key
        setState(() {
          _userKey = newUserKey;
        });

        // Close the modal
        Navigator.of(context).pop();
      } else {
        print('Error: Failed to create a new user.');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
}

class Hint {
  final String description;
  final String content;
  bool isRevealed;

  Hint(
      {required this.description,
      required this.content,
      this.isRevealed = false});
}
