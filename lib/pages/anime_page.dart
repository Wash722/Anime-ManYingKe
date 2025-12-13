import 'package:flutter/material.dart';
import '../services/bangumi_service.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import 'anime_category_page.dart';
import 'history_page.dart';
import 'anime_detail_page.dart';
import 'anime_search_page.dart';

class AnimePage extends StatefulWidget {
  const AnimePage({super.key});

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  final BangumiService _service = BangumiService();
  late Future<List<AnimeModel>> _animeFuture;

  @override
  void initState() {
    super.initState();
    _animeFuture = _service.fetchDailyAnime();
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
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withValues(alpha: 0.3), 
                              Colors.purple.withValues(alpha: 0.3)
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "本季新番一览", 
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black45)])
                          )
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(child: _buildFuncBtn("番剧分类", Icons.category, Colors.orange, () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AnimeCategoryPage()));
                          })),
                          const SizedBox(width: 20),
                          Expanded(child: _buildFuncBtn("追番表", Icons.calendar_month, Colors.blue, () {})),
                        ],
                      ),
                    ),
                    const Divider(),
                    FutureBuilder<List<AnimeModel>>(
                      future: _animeFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("暂无数据")));
                        }
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
                            final anime = list[index];
                            return AnimeCard(
                              anime: anime,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailPage(anime: anime)));
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AnimeSearchPage()));
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
                    Text("仅搜索番剧...", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
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
                const Icon(Icons.history, color: Color(0xFFD55066), size: 26),
                Text("记录", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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