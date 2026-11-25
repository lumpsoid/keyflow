import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_result.dart';
import 'history.dart';

/// Keeps [History] on the device.
class HistoryStore {
  HistoryStore(this._prefs);

  static const _key = 'history.v1';

  final SharedPreferences _prefs;

  History load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return History(const []);
    try {
      return History([
        for (final r in jsonDecode(raw) as List)
          PracticeResult.fromJson((r as Map).cast<String, Object?>()),
      ]);
    } on Object {
      // Unreadable history is lost rather than blocking practice.
      return History(const []);
    }
  }

  Future<void> save(History history) => _prefs.setString(
    _key,
    jsonEncode([for (final r in history.results) r.toJson()]),
  );
}
