import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga_model.dart';

class MangaDexService {
  static const String _baseUrl = "https://api.mangadex.org";

  Future<List<MangaModel>> searchManga(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final Uri uri = Uri.parse(
      "$_baseUrl/manga?"
      "title=$encodedKeyword&"               
      "limit=20&"                     
      "includes[]=cover_art&"         
      "contentRating[]=safe&"         
      "contentRating[]=suggestive"
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        return list.map((json) => MangaModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchChapters(String mangaId) async {
    final Uri uri = Uri.parse(
      "$_baseUrl/manga/$mangaId/feed?"
      "translatedLanguage[]=zh&"
      "translatedLanguage[]=zh-hk&"
      "translatedLanguage[]=en&"
      "translatedLanguage[]=ja&"
      "order[chapter]=desc&"
      "limit=500"
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = data['data'];
        
        return list.map((item) {
          String lang = item['attributes']['translatedLanguage'] ?? '';
          String langLabel = '';
          
          if (lang == 'zh') {
            langLabel = '[简]';
          } else if (lang == 'zh-hk') {
            langLabel = '[繁]';
          } else if (lang == 'en') {
            langLabel = '[英]';
          } else if (lang == 'ja') {
            langLabel = '[日]';
          } else {
            langLabel = '[$lang]';
          }

          String chapterNum = item['attributes']['chapter'] ?? '番外';
          String rawTitle = item['attributes']['title'] ?? '';
          String displayTitle = rawTitle.isEmpty ? "第 $chapterNum 话" : rawTitle;

          return {
            'id': item['id'],
            'chapter': chapterNum,
            'title': "$langLabel $displayTitle",
          };
        }).toList();
      } else {
        throw Exception('获取章节失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  Future<List<String>> fetchChapterImages(String chapterId) async {
    final Uri uri = Uri.parse("$_baseUrl/at-home/server/$chapterId");
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String baseUrl = data['baseUrl'];
        String hash = data['chapter']['hash'];
        List<dynamic> fileNames = data['chapter']['data']; 
        
        return fileNames.map((fileName) => "$baseUrl/data/$hash/$fileName").toList();
      } else {
        throw Exception('获取图片失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }
}