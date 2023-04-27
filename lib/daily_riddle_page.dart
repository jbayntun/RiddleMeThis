import 'package:flutter/material.dart';
import 'package:daily_riddle_app/main.dart';
import 'package:daily_riddle_app/daily_riddle.dart';
import 'api_client.dart';

class DailyRiddlePage extends StatefulWidget {
  final String userId;

  DailyRiddlePage({required this.userId});

  @override
  _DailyRiddlePageState createState() => _DailyRiddlePageState();
}

class _DailyRiddlePageState extends State<DailyRiddlePage> {
  late ApiClient apiClient;
  TextEditingController answerController = TextEditingController();
  late Future<DailyRiddle> dailyRiddle;
  final int _maxGuesses = 5;
  int _currentGuesses = 0;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient();
    dailyRiddle = apiClient.getDailyRiddle();
  }

  void _checkAnswer(String userAnswer, String correctAnswer) {
    setState(() {
      _currentGuesses++;
    });
    if (_currentGuesses >= _maxGuesses &&
        userAnswer.trim().toLowerCase() != correctAnswer.trim().toLowerCase()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Out of guesses! 😅'),
            content: Text(
                "You've used all your guesses. Don't worry, there's always tomorrow to try again!"),
          );
        },
      );
    } else if (userAnswer.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('Your answer is correct! 🎉'),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Oops!'),
            content: Text('Sorry, your answer is incorrect. Please try again.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Riddle'),
      ),
      body: Center(
        child: FutureBuilder<DailyRiddle>(
          future: dailyRiddle,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snapshot.data!.riddle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 24),
                        TextField(
                          controller: answerController,
                          decoration: InputDecoration(
                            labelText: 'Your answer',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _checkAnswer(
                              answerController.text,
                              snapshot.data!.correctAnswer,
                            );
                          },
                          child: Text('Guess Answer'),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Guess Counter',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Guesses: $_currentGuesses / $_maxGuesses',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
