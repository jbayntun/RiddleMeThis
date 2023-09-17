import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'daily_riddle.dart';

class SharedPreferencesHelper {
  static const String _userKeyPrefKey = 'user_key';
  static const String _dailyRiddlePrefKey = 'daily_riddle';
  static const String _guessesUsedPrefKey = 'guesses_used';
  static const String _usedHintsPrefKey = 'used_hints';
  static const String _puzzleCompletedPrefKey = 'puzzle_completed';
  static const String _revealedHintsPrefKey = 'revealed_hints';
  static const String _completedSuccessfullyKey = 'completed_successfully';

  static Future<String?> getUserKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKeyPrefKey);
  }

  static Future<void> setUserKey(String userKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKeyPrefKey, userKey);
  }

  static Future<void> deleteUserKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_userKeyPrefKey);
  }

  static Future<DailyRiddle?> getDailyRiddle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? riddleJson = prefs.getString(_dailyRiddlePrefKey);
    if (riddleJson != null) {
      return DailyRiddle.fromJson(json.decode(riddleJson));
    }
    return null;
  }

  static Future<void> setDailyRiddle(DailyRiddle riddle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String riddleJson = json.encode(riddle.toJson());
    prefs.setString(_dailyRiddlePrefKey, riddleJson);
  }

  static Future<void> deleteDailyRiddle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_dailyRiddlePrefKey);
  }

  static Future<void> setGuessesUsed(int guessesUsed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_guessesUsedPrefKey, guessesUsed);
  }

  static Future<int?> getGuessesUsed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_guessesUsedPrefKey);
  }

  static Future<void> setUsedHints(int usedHints) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_usedHintsPrefKey, usedHints);
  }

  static Future<int?> getUsedHints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_usedHintsPrefKey);
  }

  static Future<void> setPuzzleCompleted(bool puzzleCompleted) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_puzzleCompletedPrefKey, puzzleCompleted);
  }

  static Future<bool?> getPuzzleCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_puzzleCompletedPrefKey);
  }

  static Future<void> setCompletedSuccessfully(bool successful) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_completedSuccessfullyKey, successful);
  }

  static Future<bool?> getCompletedSuccessfully() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedSuccessfullyKey);
  }

  static Future<void> setRevealedHints(Set<int> revealedHints) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hintsAsString = revealedHints.join(",");
    prefs.setString(_revealedHintsPrefKey, hintsAsString);
  }

  static Future<Set<int>?> getRevealedHints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hintsAsString = prefs.getString(_revealedHintsPrefKey);
    if (hintsAsString != null) {
      Iterable<int> hintsAsInts = hintsAsString.split(",").map(int.parse);
      return Set<int>.from(hintsAsInts);
    }
    return null;
  }

  static Future<void> deleteGameData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_guessesUsedPrefKey);
    prefs.remove(_usedHintsPrefKey);
    prefs.remove(_puzzleCompletedPrefKey);
    prefs.remove(_revealedHintsPrefKey);
    prefs.remove(_completedSuccessfullyKey);
  }
}
