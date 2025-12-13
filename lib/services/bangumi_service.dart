import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/anime_model.dart';

class BangumiService {
  static const String _accessToken = "1G4kABKbsJmnrdiPrayiJHcen3BoCH5MQGFTvkRC";
  static const String _keyDailyCache = "daily_anime_cache";
  static const String _keyMangaCache = "popular_manga_cache";
  static const int _pageSize = 24;

  // 【核心修复】恢复 fetchDailyAnime 的完整实现
  Future<List<AnimeModel>> fetchDailyAnime({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cache = await _getFromCache(_keyDailyCache);
      if (cache.isNotEmpty) {
        debugPrint("命中番剧缓存，直接返回！");
        _fetchAndCacheDaily(); // 后台静默更新
        return cache.map((e) => e.copyWith(type: 'anime')).toList();
      }
    }
    return _fetchAndCacheDaily();
  }

  Future<List<AnimeModel>> _fetchAndCacheDaily() async {
    final Uri uri = Uri.parse("https://api.bgm.tv/calendar");
    final headers = {'Authorization': 'Bearer $_accessToken', 'User-Agent': 'FlutterApp/1.0'};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyDailyCache, response.body);
        return _parseDailyJson(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("番剧API错误: $e");
      return [];
    }
  }

  // 【核心修复】恢复 fetchPopularManga 的完整实现
  Future<List<AnimeModel>> fetchPopularManga() async {
    final cache = await _getFromCache(_keyMangaCache);
    if (cache.isNotEmpty) {
      return cache.map((e) => e.copyWith(type: 'manga')).toList();
    }

    final String keyword = Uri.encodeComponent("漫画");
    final Uri uri = Uri.parse("https://api.bgm.tv/search/subject/$keyword?type=1&responseGroup=medium&max_results=20");
    final headers = {'Authorization': 'Bearer $_accessToken', 'User-Agent': 'FlutterApp/1.0', 'Accept': 'application/json'};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyMangaCache, response.body);
        final data = json.decode(response.body);
        if (data['list'] != null) {
          return (data['list'] as List).map((json) => AnimeModel.fromJson(json).copyWith(type: 'manga')).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("漫画API报错: $e");
      return [];
    }
  }

  // searchSubject 方法保持不变
  Future<List<AnimeModel>> searchSubject(String keyword, {int type = 2, int page = 1}) async {
    if (keyword.isEmpty) return [];
    final int offset = (page - 1) * _pageSize;
    final encodedKey = Uri.encodeComponent(keyword);
    final Uri uri = Uri.parse(
      "https://api.bgm.tv/search/subject/$encodedKey?type=$type&responseGroup=medium&max_results=$_pageSize&start=$offset"
    );
    final headers = {'Authorization': 'Bearer $_accessToken'};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['list'] != null) {
          final String typeStr = (type == 1) ? 'manga' : 'anime';
          return (data['list'] as List).map((json) => AnimeModel.fromJson(json).copyWith(type: typeStr)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 【核心修复】恢复 _getFromCache 和 _parseDailyJson
  Future<List<AnimeModel>> _getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(key);
    if (jsonString != null && jsonString.isNotEmpty) {
      if (key == _keyDailyCache) {
        return _parseDailyJson(jsonString);
      } else {
        final data = json.decode(jsonString);
        if (data['list'] != null) {
          return (data['list'] as List).map((json) => AnimeModel.fromJson(json)).toList();
        }
      }
    }
    return [];
  }

  List<AnimeModel> _parseDailyJson(String jsonBody) {
    List<dynamic> data = json.decode(jsonBody);
    List<AnimeModel> allAnime = [];
    for (var day in data) {
      if (day['items'] != null) {
        for (var item in day['items']) {
          allAnime.add(AnimeModel.fromJson(item).copyWith(type: 'anime'));
        }
      }
    }
    return allAnime;
  }
}