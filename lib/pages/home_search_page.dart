import 'package:flutter/material.dart';
import '../services/bangumi_service.dart';
import '../models/anime_model.dart';
import 'anime_detail_page.dart';
import 'manga_search_page.dart';

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({super.key});

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> with SingleTickerProviderStateMixin {
  final BangumiService _service = BangumiService();
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  
  final ScrollController _animeScrollController = ScrollController();
  final ScrollController _mangaScrollController = ScrollController();

  List<AnimeModel> _animeResults = [];
  List<AnimeModel> _mangaResults = [];
  
  int _animePage = 1;
  int _mangaPage = 1;
  bool _hasMoreAnime = true;
  bool _hasMoreManga = true;
  bool _isLoading = false;
  bool _isNextPageLoading = false;

  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animeScrollController.addListener(() {
      if (_animeScrollController.position.pixels == _animeScrollController.position.maxScrollExtent && !_isNextPageLoading && _hasMoreAnime) {
        _loadNextPage();
      }
    });
    _mangaScrollController.addListener(() {
      if (_mangaScrollController.position.pixels == _mangaScrollController.position.maxScrollExtent && !_isNextPageLoading && _hasMoreManga) {
        _loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animeScrollController.dispose();
    _mangaScrollController.dispose();
    super.dispose();
  }

  void _doSearch() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _animeResults.clear();
      _mangaResults.clear();
      _animePage = 1;
      _mangaPage = 1;
      _hasMoreAnime = true;
      _hasMoreManga = true;
    });
    FocusScope.of(context).unfocus();

    final animeFuture = _service.searchSubject(_controller.text, type: 2, page: 1);
    final mangaFuture = _service.searchSubject(_controller.text, type: 1, page: 1);

    final results = await Future.wait([animeFuture, mangaFuture]);

    if (mounted) {
      setState(() {
        _animeResults = results[0];
        _mangaResults = results[1];
        if (results[0].length < 24) _hasMoreAnime = false;
        if (results[1].length < 24) _hasMoreManga = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isNextPageLoading = true;
    });

    final isAnimeTab = _tabController.index == 0;
    
    List<AnimeModel> newResults = [];
    if (isAnimeTab) {
      _animePage++;
      newResults = await _service.searchSubject(_controller.text, type: 2, page: _animePage);
    } else {
      _mangaPage++;
      newResults = await _service.searchSubject(_controller.text, type: 1, page: _mangaPage);
    }

    if (mounted) {
      setState(() {
        if (isAnimeTab) {
          _animeResults.addAll(newResults);
          if (newResults.length < 24) _hasMoreAnime = false;
        } else {
          _mangaResults.addAll(newResults);
          if (newResults.length < 24) _hasMoreManga = false;
        }
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
        // 【核心修复】把完整的 AppBar 加回来
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 1, // 加一点阴影好看
        shadowColor: Colors.grey[100],
        leading: const BackButton(color: Colors.black),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _doSearch(), // 在这里使用了 _doSearch
            decoration: InputDecoration(
              hintText: "搜索番剧或漫画...",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _doSearch, // 在这里也使用了 _doSearch
            child: const Text("搜索", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: themeColor,
          tabs: const [ Tab(text: "番剧"), Tab(text: "漫画") ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: themeColor))
        : !_hasSearched
          ? Center(child: Text("输入关键词，同时搜索双端资源", style: TextStyle(color: Colors.grey[400])))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_animeResults, _animeScrollController, hasMore: _hasMoreAnime, isManga: false),
                _buildList(_mangaResults, _mangaScrollController, hasMore: _hasMoreManga, isManga: true),
              ],
            ),
    );
  }

  Widget _buildList(List<AnimeModel> list, ScrollController controller, {required bool hasMore, required bool isManga}) {
    if (list.isEmpty) {
      return Center(child: Text("没有找到相关内容", style: TextStyle(color: Colors.grey[400])));
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (hasMore || _isNextPageLoading ? 1 : 0),
      separatorBuilder: (c,i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return _isNextPageLoading 
            ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2))) 
            : const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("--- 我是有底线的 ---", style: TextStyle(color: Colors.grey))));
        }

        // 【核心修复】在这里使用了 item
        final item = list[index];
        return GestureDetector(
          onTap: () {
            if (isManga) {
               Navigator.push(context, MaterialPageRoute(builder: (c) => MangaSearchPage(keyword: item.displayName, coverUrl: item.imageUrl, id: item.id)));
            } else {
               Navigator.push(context, MaterialPageRoute(builder: (c) => AnimeDetailPage(anime: item)));
            }
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
                      const Spacer(), // 占位符，让下面的文字靠底
                      Text(item.airDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}