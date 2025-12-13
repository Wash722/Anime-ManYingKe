import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_model.dart';

class StorageService {
  static const String _keyHistory = "history_list";

  Future<void> addHistory(AnimeModel anime) async {
    final prefs = await SharedPreferences.getInstance();
    List<AnimeModel> history = await getHistory();

    history.removeWhere((element) => element.id == anime.id);
    history.insert(0, anime);

    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    List<String> jsonList = history.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_keyHistory, jsonList);
  }

  Future<List<AnimeModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_keyHistory);
    
    if (jsonList == null) return [];

    return jsonList.map((str) => AnimeModel.fromJson(json.decode(str))).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }
}