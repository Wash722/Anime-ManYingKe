import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/mangadex_service.dart';
import '../models/manga_model.dart';
import '../models/anime_model.dart'; 
import '../services/storage_service.dart';
import 'manga_detail_page.dart';

class MangaSearchPage extends StatefulWidget {
  final String keyword; 
  final String coverUrl;
  final int id; 

  const MangaSearchPage({
    super.key, 
    required this.keyword, 
    required this.coverUrl,
    this.id = 0,
  });

  @override
  State<MangaSearchPage> createState() => _MangaSearchPageState();
}

class _MangaSearchPageState extends State<MangaSearchPage> {
  final MangaDexService _service = MangaDexService();
  final StorageService _storage = StorageService();

  late Future<List<MangaModel>> _searchFuture;
  final TextEditingController _searchController = TextEditingController();
  
  final Color _themeColor = const Color(0xFFD55066);

  @override
  void initState() {
    super.initState();
    _saveHistory();
    String cleanKeyword = widget.keyword.replaceAll(RegExp(r"\(.*?\)|（.*?）"), "").trim();
    _searchController.text = cleanKeyword;
    _doSearch(cleanKeyword);
  }

  void _saveHistory() {
    final historyItem = AnimeModel(
      id: widget.id,
      name: widget.keyword,
      nameCn: widget.keyword,
      imageUrl: widget.coverUrl,
      type: 'manga',
    );
    _storage.addHistory(historyItem);
  }

  void _doSearch(String key) {
    setState(() {
      _searchFuture = _service.searchManga(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("匹配阅读源"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(color: Colors.grey[900]),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: _themeColor,
                          decoration: InputDecoration(
                            hintText: "自动匹配失败？试试搜英文名...",
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  _doSearch(_searchController.text);
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) => _doSearch(value),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "提示：MangaDex 对中文支持一般，搜不到请尝试输入【英文】或【罗马音】标题",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<MangaModel>>(
                    future: _searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 16),
                              Text("正在 MangaDex 图书馆检索...", style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                            ],
                          ),
                        );
                      }
                      
                      final results = snapshot.data ?? [];
                      
                      if (results.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.menu_book_outlined, size: 60, color: Colors.white.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  "未找到《${_searchController.text}》", 
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final manga = results[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MangaDetailPage(manga: manga)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                    child: Image.network(
                                      manga.coverUrl, width: 80, height: 110, fit: BoxFit.cover,
                                      errorBuilder: (c,e,s) => Container(width: 80, height: 110, color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.white24)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(manga.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: _themeColor, borderRadius: BorderRadius.circular(4)),
                                                child: const Text("MangaDex", style: TextStyle(color: Colors.white, fontSize: 10)),
                                              ),
                                              const SizedBox(width: 8),
                                              Text("ID: ${manga.id.substring(0, 5)}...", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white.withValues(alpha: 0.5)),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}