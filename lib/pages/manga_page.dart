import 'package:flutter/material.dart';
import '../services/bangumi_service.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import 'history_page.dart';         
import 'manga_search_page.dart';    
import 'manga_query_page.dart';     

class MangaPage extends StatefulWidget {
  const MangaPage({super.key});

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  final BangumiService _service = BangumiService();
  late Future<List<AnimeModel>> _mangaFuture;

  @override
  void initState() {
    super.initState();
    _mangaFuture = _service.fetchPopularManga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 180,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                                Colors.purple.withValues(alpha: 0.4), 
                                Colors.pink.withValues(alpha: 0.4)
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "热门漫画推荐", 
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black45)])
                          )
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(child: _buildFuncBtn("分类索引", Icons.style, Colors.purple, () {})),
                          const SizedBox(width: 20),
                          Expanded(child: _buildFuncBtn("排行榜", Icons.trending_up, Colors.red, () {})),
                        ],
                      ),
                    ),
                    const Divider(),
                    FutureBuilder<List<AnimeModel>>(
                      future: _mangaFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("暂无数据"));
                        final list = snapshot.data!;
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: list.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.65,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final manga = list[index];
                            return AnimeCard(
                              anime: manga,
                              onTap: () {
                                 Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MangaSearchPage(
                                        keyword: manga.displayName, 
                                        coverUrl: manga.imageUrl,
                                        id: manga.id,
                                      ),
                                    ),
                                  );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
             child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MangaQueryPage()));
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD55066), width: 2.0),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Color(0xFFD55066), size: 20),
                    const SizedBox(width: 8),
                    Text("仅搜索漫画...", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_edu, color: Color(0xFFD55066), size: 26), 
                Text("历史", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuncBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}