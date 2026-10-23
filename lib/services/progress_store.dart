import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/puzzle.dart';

String dateKey(DateTime value) => [
      value.year.toString().padLeft(4, '0'),
      value.month.toString().padLeft(2, '0'),
      value.day.toString().padLeft(2, '0'),
    ].join('-');

class PlayerProgress {
  const PlayerProgress({
    this.solved = const {},
    this.score = 0,
    this.attempts = const {},
    this.correctByMode = const {},
    this.streakByMode = const {},
    this.reviewDue = const {},
    this.dailyCompletions = const {},
  });

  final Map<String, int> solved;
  final int score;
  final Map<String, int> attempts;
  final Map<String, int> correctByMode;
  final Map<String, int> streakByMode;
  final Map<String, String> reviewDue;
  final Set<String> dailyCompletions;

  int get solvedCount => solved.length;
  int get totalStars => solved.values.fold(0, (total, stars) => total + stars);
  int attemptsFor(PuzzleMode mode) => attempts[mode.name] ?? 0;
  int correctFor(PuzzleMode mode) => correctByMode[mode.name] ?? 0;
  int streakFor(PuzzleMode mode) => streakByMode[mode.name] ?? 0;

  int targetDifficulty(PuzzleMode mode) {
    final tried = attemptsFor(mode);
    if (tried == 0) return 1;
    final ratio = correctFor(mode) / tried;
    if (ratio >= .85) return 4;
    if (ratio >= .65) return 3;
    if (ratio >= .4) return 2;
    return 1;
  }

  int dailyStreak([DateTime? now]) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    var cursor = dailyCompletions.contains(dateKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    var count = 0;
    while (dailyCompletions.contains(dateKey(cursor))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  PlayerProgress recordWrong(String id, PuzzleMode mode, DateTime date) {
    final due = DateTime(date.year, date.month, date.day).add(const Duration(days: 1));
    return PlayerProgress(
      solved: solved,
      score: score,
      attempts: {...attempts, mode.name: attemptsFor(mode) + 1},
      correctByMode: correctByMode,
      streakByMode: {...streakByMode, mode.name: 0},
      reviewDue: {...reviewDue, id: dateKey(due)},
      dailyCompletions: dailyCompletions,
    );
  }

  PlayerProgress solve(String id, int stars, int points,
      {PuzzleMode? mode, DateTime? date, bool daily = false}) {
    if (solved.containsKey(id)) return this;
    final activeMode = mode ?? PuzzleMode.logic;
    final today = date ?? DateTime.now();
    final daysUntilReview = stars >= 3 ? 7 : stars == 2 ? 3 : 1;
    final due = DateTime(today.year, today.month, today.day)
        .add(Duration(days: daysUntilReview));
    final completion = dateKey(today);
    return PlayerProgress(
      solved: {...solved, id: stars.clamp(1, 3).toInt()},
      score: score + points,
      attempts: {...attempts, activeMode.name: attemptsFor(activeMode) + 1},
      correctByMode: {...correctByMode, activeMode.name: correctFor(activeMode) + 1},
      streakByMode: {...streakByMode, activeMode.name: streakFor(activeMode) + 1},
      reviewDue: {...reviewDue, id: dateKey(due)},
      dailyCompletions: daily
          ? {...dailyCompletions, completion}
          : dailyCompletions,
    );
  }

  Map<String, dynamic> toJson() => {
        'solved': solved,
        'score': score,
        'attempts': attempts,
        'correctByMode': correctByMode,
        'streakByMode': streakByMode,
        'reviewDue': reviewDue,
        'dailyCompletions': dailyCompletions.toList()..sort(),
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    Map<String, int> readInts(Object? value, {int? max}) {
      final result = <String, int>{};
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.key is String && entry.value is num) {
            final number = (entry.value as num).toInt();
            result[entry.key as String] =
                max == null ? number : number.clamp(0, max).toInt();
          }
        }
      }
      return result;
    }

    final due = <String, String>{};
    final rawDue = json['reviewDue'];
    if (rawDue is Map) {
      for (final entry in rawDue.entries) {
        if (entry.key is String && entry.value is String) {
          due[entry.key as String] = entry.value as String;
        }
      }
    }
    final rawDays = json['dailyCompletions'];
    final days = rawDays is List ? rawDays.whereType<String>().toSet() : <String>{};
    return PlayerProgress(
      solved: readInts(json['solved'], max: 3),
      score: (json['score'] as num?)?.toInt() ?? 0,
      attempts: readInts(json['attempts']),
      correctByMode: readInts(json['correctByMode']),
      streakByMode: readInts(json['streakByMode']),
      reviewDue: due,
      dailyCompletions: days,
    );
  }
}

class ProgressStore {
  static const _key = 'zihinlab.progress.v1';

  Future<PlayerProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const PlayerProgress();
    try {
      return PlayerProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerProgress();
    }
  }

  Future<void> save(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }
}
