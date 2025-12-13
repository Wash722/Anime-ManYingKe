import 'package:flutter/material.dart';
import '../services/bangumi_service.dart';
import '../models/anime_model.dart';
import 'manga_search_page.dart';

class MangaQueryPage extends StatefulWidget {
  const MangaQueryPage({super.key});

  @override
  State<MangaQueryPage> createState() => _MangaQueryPageState();
}

class _MangaQueryPageState extends State<MangaQueryPage> {
  final BangumiService _service = BangumiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AnimeModel> _results = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isNextPageLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isNextPageLoading && _hasMore) {
        _loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _doSearch() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _results.clear();
      _page = 1;
      _hasMore = true;
    });
    FocusScope.of(context).unfocus();

    // 强制 type = 1 (漫画)
    final list = await _service.searchSubject(_controller.text, type: 1, page: 1);
    
    if (mounted) {
      setState(() {
        _results = list;
        if (list.length < 24) _hasMore = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    setState(() => _isNextPageLoading = true);
    _page++;
    final newResults = await _service.searchSubject(_controller.text, type: 1, page: _page);

    if (mounted) {
      setState(() {
        _results.addAll(newResults);
        if (newResults.length < 24) _hasMore = false;
        _isNextPageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFD55066);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[100],
        leading: const BackButton(color: Colors.black),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _doSearch(),
            decoration: InputDecoration(
              hintText: "仅搜索漫画...",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.menu_book, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: _doSearch, child: const Text("搜漫", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)))
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: themeColor))
        : !_hasSearched
          ? Center(child: Text("输入漫画名开始搜索", style: TextStyle(color: Colors.grey[400])))
          : _results.isEmpty
            ? Center(child: Text("没有找到相关漫画", style: TextStyle(color: Colors.grey[400])))
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _results.length + (_hasMore || _isNextPageLoading ? 1 : 0),
                separatorBuilder: (c,i) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == _results.length) {
                    return _isNextPageLoading 
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2))) 
                      : const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("--- 我是有底线的 ---", style: TextStyle(color: Colors.grey))));
                  }

                  final item = _results[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (c) => MangaSearchPage(
                          keyword: item.displayName, 
                          coverUrl: item.imageUrl,
                          id: item.id,
                        ))
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, width: 90, height: 120, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 90, height: 120, color: Colors.grey[200])),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 6),
                                if (item.score != null && item.score! > 0)
                                   Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(" ${item.score}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))]),
                                const Spacer(),
                                Text(item.airDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
    );
  }
}