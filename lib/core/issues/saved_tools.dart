import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bookmarks and recently opened tools, kept on this phone only.
///
/// Nothing here leaves the device. A list of the tools someone opens says a
/// great deal about them - a woman opening the domestic violence screens,
/// a family opening the ration appeal - so it is never sent anywhere, and
/// it can be wiped from Settings in one tap.
class SavedTools extends ChangeNotifier {
  static const _savedKey = 'saved_tools_v1';
  static const _recentKey = 'recent_tools_v1';
  static const maxRecent = 12;

  List<String> _saved = const [];
  List<String> _recent = const [];

  List<String> get saved => _saved;
  List<String> get recent => _recent;

  bool isSaved(String id) => _saved.contains(id);

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    _saved = prefs.getStringList(_savedKey) ?? const [];
    _recent = prefs.getStringList(_recentKey) ?? const [];
    notifyListeners();
  }

  Future<void> toggleSaved(String id) async {
    final next = [..._saved];
    next.contains(id) ? next.remove(id) : next.insert(0, id);
    _saved = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, next);
  }

  Future<void> markOpened(String id) async {
    final next = [id, ..._recent.where((x) => x != id)];
    if (next.length > maxRecent) next.removeRange(maxRecent, next.length);
    if (listEquals(next, _recent)) return;
    _recent = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, next);
  }

  Future<void> clearAll() async {
    _saved = const [];
    _recent = const [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedKey);
    await prefs.remove(_recentKey);
  }
}
