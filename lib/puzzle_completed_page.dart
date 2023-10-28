import 'package:daily_riddle_app/daily_riddle.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'api_client.dart';
import 'utils.dart';

class PuzzleCompletedPage extends StatefulWidget {
  final bool isSuccess;
  final String correctAnswer;
  final int guessesUsed;
  final int hintsUsed;
  final Duration timeTaken; // time in seconds
  final Future<DailyRiddle>? currentRiddle;

  PuzzleCompletedPage({
    required this.isSuccess,
    required this.correctAnswer,
    required this.guessesUsed,
    required this.hintsUsed,
    required this.timeTaken,
    required this.currentRiddle,
  });

  @override
  _PuzzleCompletedPageState createState() => _PuzzleCompletedPageState();
}

class _PuzzleCompletedPageState extends State<PuzzleCompletedPage>
    with WidgetsBindingObserver {
  late Future<Map<String, dynamic>?> _fetchStatsFuture;
  Timer? _riddleCheckTimer;
  final apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _riddleCheckTimer = Timer.periodic(
        Duration(minutes: 5),
        (Timer t) =>
            ModalUtils.getNewRiddle(widget.currentRiddle, apiClient, context));
    _fetchStatsFuture = _fetchStatisticsData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ModalUtils.getNewRiddle(widget.currentRiddle, apiClient, context);
    }
  }

  Future<Map<String, dynamic>?> _fetchStatisticsData() async {
    return await apiClient.getStatistics();
  }

  void _showStatsModal(BuildContext context, Map<String, dynamic> stats) {
    Map<String, dynamic> statistics =
        Map<String, dynamic>.from(stats['statistics']);

    Map<String, String> readableTitles = {
      'average_guesses': 'Average Guesses',
      'average_time': 'Average Time',
      'success_rate': 'Success Rate',
      'win_streak': 'Win Streak',
      'max_win_streak': 'Max Win Streak',
    };

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 16), // spacing between the title and the stats
              ...statistics.entries.map(
                (entry) => ListTile(
                  title: Text(readableTitles[entry.key] ?? 'Unknown'),
                  subtitle: Text(entry.value.toString()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
    String elapsedTime = formatDuration(widget.timeTaken);
    String shareText = '';

    if (widget.isSuccess) {
      shareText = '🎉 I just completed the Daily Riddle! 🎉\n\n';
      shareText += 'Guesses used: ${widget.guessesUsed}\n';
      shareText += 'Hints used: ${widget.hintsUsed}\n';
      shareText += 'Time taken: $elapsedTime';
    }

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            _showStatsModal(context, snapshot.data!);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Puzzle Completed'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => ModalUtils.showUserIdModal(context),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.isSuccess
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
                  widget.isSuccess
                      ? 'You guessed the correct answer!'
                      : 'You\'ve used all your guesses.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                widget.isSuccess
                    ? Container()
                    : Column(
                        children: [
                          Text(
                            'The correct answer was:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            widget.correctAnswer,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 24),
                widget.isSuccess
                    ? ElevatedButton(
                        onPressed: _sharePuzzleCompletion,
                        child: Text('Share'),
                      )
                    : Container(),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showStatsModal(context, snapshot.data!),
                  child: Text('Show Statistics'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
