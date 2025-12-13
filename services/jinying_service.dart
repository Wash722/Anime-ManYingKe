import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class JinyingService {
  final String _searchApiUrl = "https://jyzyapi.com/provide/vod/at/json/";

  // 精准搜索的内部函数
  Future<int?> _directSearch(String keyword) async {
    if (keyword.isEmpty) return null;

    final encodedName = Uri.encodeComponent(keyword);
    final searchUrl = Uri.parse("$_searchApiUrl?ac=detail&wd=$encodedName");

    try {
      debugPrint("【精准搜索】正在尝试: '$keyword'");
      final response = await http.get(searchUrl);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 1 && (data['list'] as List).isNotEmpty) {
          final vodId = data['list'][0]['vod_id'];
          debugPrint("🎉 精准搜索成功！ VOD_ID: $vodId");
          return vodId;
        }
      }
    } catch (e) {
      debugPrint("【精准搜索】失败: $e");
    }
    return null;
  }

  // 模糊搜索的内部函数
  String _getSimplifiedName(String name) {
    name = name.replaceAll(RegExp(r"\(.*?\)|（.*?）|\[.*?\]|【.*?】"), "");
    final separators = RegExp(r":|：|—|~| Season| 第");
    final match = separators.firstMatch(name);
    if (match != null) {
      name = name.substring(0, match.start);
    }
    return name.trim();
  }

  // “总指挥”
  Future<int?> searchVodId(String fullName, {String? originalName}) async {
    int? vodId;

    // --- 第一轮：精准打击 ---
    vodId = await _directSearch(fullName);
    if (vodId != null) return vodId;

    if (originalName != null && originalName.isNotEmpty && originalName != fullName) {
      vodId = await _directSearch(originalName);
      if (vodId != null) return vodId;
    }

    // --- 第二轮：模糊打击 ---
    debugPrint("⚠️ 精准搜索失败，启动模糊搜索...");
    
    String simplifiedName = _getSimplifiedName(fullName);
    if (simplifiedName.isNotEmpty && simplifiedName != fullName) {
      vodId = await _directSearch(simplifiedName);
      if (vodId != null) return vodId;
    }
    
    debugPrint("【智能搜索】所有策略均失败，未找到资源。");
    return null;
  }

  // fetchPlayableEpisodes 方法
  Future<List<Map<String, String>>> fetchPlayableEpisodes(int vodId) async {
    final detailUrl = Uri.parse("$_searchApiUrl?ac=detail&ids=$vodId");
    try {
      final response = await http.get(detailUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 1 && (data['list'] as List).isNotEmpty) {
          final videoData = data['list'][0];
          final playFrom = videoData['vod_play_from']?.split('\$\$\$') ?? [];
          final playUrls = (videoData['vod_play_url'] as String).split('\$\$\$');
          
          int m3u8Index = playFrom.indexWhere((element) => (element as String).contains('m3u8'));

          if (m3u8Index != -1 && m3u8Index < playUrls.length) {
            final List<Map<String, String>> episodes = [];
            final m3u8Urls = playUrls[m3u8Index];
            final parts = m3u8Urls.split('#');

            for (var part in parts) {
              final episodeData = part.split('\$');
              if (episodeData.length == 2 && episodeData[1].contains('.m3u8')) {
                episodes.add({'name': episodeData[0], 'url': episodeData[1]});
              }
            }
            return episodes;
          }
        }
      }
    } catch (e) {
      debugPrint("获取详情失败: $e");
    }
    return [];
  }
}