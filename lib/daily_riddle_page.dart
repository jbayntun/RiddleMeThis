import 'package:daily_riddle_app/puzzle_completed_page.dart';
import 'package:flutter/material.dart';
import 'package:daily_riddle_app/main.dart';
import 'package:daily_riddle_app/daily_riddle.dart';
import 'api_client.dart';
import 'user_key_helper.dart';
import 'utils.dart';

import 'dart:async';

class DailyRiddlePage extends StatefulWidget {
  final String userId;

  DailyRiddlePage({required this.userId});

  @override
  _DailyRiddlePageState createState() => _DailyRiddlePageState();
}

class _DailyRiddlePageState extends State<DailyRiddlePage> {
  late ApiClient apiClient;
  TextEditingController answerController = TextEditingController();
  Future<DailyRiddle>? dailyRiddle;
  final int _maxGuesses = 5;
  int _guessesUsed = 0;
  int _usedHints = 0;
  bool _puzzleCompleted = false;
  Set<int> _revealedHints = Set();
  Timer? _timer;
  Duration _elapsedTime = Duration();

  @override
  void initState() {
    super.initState();
    dailyRiddle = null;
    _initialize();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (!_puzzleCompleted) {
          setState(() {
            _elapsedTime = _elapsedTime + Duration(seconds: 1);
          });
        } else {
          _timer?.cancel();
        }
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    apiClient = ApiClient();
    String? userId = await UserKeyHelper.getUserKey();
    if (userId != null) {
      dailyRiddle = apiClient.getDailyRiddle(userId);
    } else {
      // Handle the case when the user ID is not available
      // You can show an error message or redirect to a different page
    }
  }

  void _showErrorDialog(int errorCode, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error $errorCode'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHintsDialog(BuildContext context, List<Hint> hints) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Hints'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: hints.asMap().entries.map((entry) {
                    int index = entry.key;
                    Hint hint = entry.value;
                    bool hintRevealed = _revealedHints.contains(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hint.description,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          hintRevealed
                              ? Text(
                                  hint.hint,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _revealedHints.add(index);
                                    });

                                    this.setState(() {
                                      _usedHints++;
                                    });
                                  },
                                  child: Text('Reveal Hint'),
                                ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _checkAnswer(String answer, String correctAnswer, int riddleId) {
    if (answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      setState(() {
        _guessesUsed++;
        _puzzleCompleted = true;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleCompletedPage(
            isSuccess: true,
            correctAnswer: correctAnswer,
            guessesUsed: _guessesUsed,
            hintsUsed: _usedHints,
            timeTaken: _elapsedTime,
            riddleId: riddleId,
          ),
        ),
      );
    } else {
      setState(() {
        _guessesUsed++;
        answerController.clear(); // Clear the input after an incorrect guess
      });

      if (_guessesUsed >= _maxGuesses) {
        setState(() {
          _puzzleCompleted = true;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleCompletedPage(
              isSuccess: false,
              correctAnswer: correctAnswer,
              guessesUsed: _guessesUsed,
              hintsUsed: _usedHints,
              timeTaken: _elapsedTime,
              riddleId: riddleId,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _getIncorrectGuessDialog();
          },
        );
      }
    }
  }

  Widget _getIncorrectGuessDialog() {
    return AlertDialog(
      title: Text('Oops!'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('That guess was incorrect. Try again!'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Riddle'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => ModalUtils.showUserIdModal(context),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<DailyRiddle>(
          future: dailyRiddle,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 24),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _checkAnswer(
                                      answerController.text,
                                      snapshot.data!.correctAnswer,
                                      snapshot.data!.id,
                                    );
                                  },
                                  child: Text('Guess Answer'),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      8), // Optional: add some space between the buttons
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showHintsDialog(
                                        context, snapshot.data!.hints);
                                  },
                                  child: Text('Hints'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
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
                                'Guesses: $_guessesUsed / $_maxGuesses',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hints',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Used: $_usedHints / ${snapshot.data!.hints.length}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _formatDuration(_elapsedTime),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
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
