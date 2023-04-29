import 'package:flutter/material.dart';
import 'package:share/share.dart';

class PuzzleCompletedPage extends StatelessWidget {
  final bool isSuccess;
  final String correctAnswer;
  final int guessesUsed;
  final int hintsUsed;
  final Duration timeTaken; // time in seconds

  PuzzleCompletedPage({
    required this.isSuccess,
    required this.correctAnswer,
    required this.guessesUsed,
    required this.hintsUsed,
    required this.timeTaken,
  });

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    List<String> formattedParts = [];

    if (duration.inHours > 0) {
      formattedParts.add('$hours hours');
    }
    if (duration.inMinutes > 0) {
      formattedParts.add('$minutes minutes');
    }
    formattedParts.add('$seconds seconds');

    return formattedParts.join(', ');
  }

  Future<void> _sharePuzzleCompletion() async {
    String elapsedTime = formatDuration(timeTaken);
    String shareText = '';

    if (isSuccess) {
      shareText = '🎉 I just completed the Daily Riddle! 🎉\n\n';
      shareText += 'Guesses used: $guessesUsed\n';
      shareText += 'Hints used: $hintsUsed\n';
      shareText += 'Time taken: $elapsedTime';
    }

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Completed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSuccess
                ? Text(
                    'Congratulations! 🎉',
                    style: TextStyle(fontSize: 24),
                  )
                : Text(
                    'Oh no! 😔',
                    style: TextStyle(fontSize: 24),
                  ),
            SizedBox(height: 16),
            Text(
              isSuccess
                  ? 'You guessed the correct answer!'
                  : 'You\'ve used all your guesses.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            isSuccess
                ? Container()
                : Column(
                    children: [
                      Text(
                        'The correct answer was:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        correctAnswer,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 24),
            isSuccess
                ? ElevatedButton(
                    onPressed: _sharePuzzleCompletion,
                    child: Text('Share'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
