import 'dart:async';
import 'dart:math';

Future<Map<String, dynamic>> fetchRiddle() async {
  await Future.delayed(Duration(milliseconds: 500)); // Simulate server delay
  return {
    'riddle': "What has keys but can't open locks?",
    'correctAnswer': 'piano',
    'hints': [
      {'description': "Number of letters", 'content': "5"},
      {'description': "Rhymes with", 'content': "bianco"},
    ],
  };
}
