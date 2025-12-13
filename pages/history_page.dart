import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/anime_model.dart';
import 'anime_detail_page.dart';
import 'manga_search_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final StorageService _storage = StorageService();
  
  List<AnimeModel> _animeList = [];
  List<AnimeModel> _mangaList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final list = await _storage.getHistory();
    if (mounted) {
      setState(() {
        _animeList = list.where((e) => e.type == 'anime').toList();
        _mangaList = list.where((e) => e.type == 'manga').toList();
      });
    }
  }

  void _clearHistory() {
    _storage.clearHistory();
    setState(() {
      _animeList.clear();
      _mangaList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFD55066);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("足迹"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "清空历史",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("清空记录"),
                    content: const Text("确定要删除所有浏览历史吗？"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("取消")),
                      TextButton(
                        onPressed: () {
                          _clearHistory();
                          Navigator.pop(ctx);
                        }, 
                        child: const Text("清空", style: TextStyle(color: Colors.red))
                      ),
                    ],
                  )
                );
              },
            )
          ],
          bottom: const TabBar(
            labelColor: themeColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: themeColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "番剧"),
              Tab(text: "漫画"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_animeList, isManga: false),
            _buildList(_mangaList, isManga: true),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<AnimeModel> list, {required bool isManga}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isManga ? Icons.menu_book : Icons.movie_filter, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isManga ? "还没有看过漫画哦" : "还没有追过番剧哦",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: list.length,
      separatorBuilder: (c, i) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.imageUrl, 
              width: 50, height: 70, fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(width: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
            ),
          ),
          title: Text(item.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text("ID: ${item.id}", style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {
            if (isManga) {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (c) => MangaSearchPage(
                  keyword: item.displayName, 
                  coverUrl: item.imageUrl,
                  id: item.id,
                ))
              );
            } else {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (c) => AnimeDetailPage(anime: item))
              );
            }
          },
        );
      },
    );
  }
}