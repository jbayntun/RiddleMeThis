import 'package:flutter/material.dart';

class FailurePage extends StatefulWidget {
  final String correctAnswer;

  FailurePage({required this.correctAnswer});

  @override
  _FailurePageState createState() => _FailurePageState();
}

class _FailurePageState extends State<FailurePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oh no! 😔'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("You've used all your guesses."),
            SizedBox(height: 10), // Add some space between the lines
            Text('The correct answer was:'),
            Text(
              widget.correctAnswer, // Display the correct answer
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // Add some space between the lines
            Text("Don't worry, you'll have another chance tomorrow!"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Daily Riddle'),
            ),
          ],
        ),
      ),
    );
  }
}
