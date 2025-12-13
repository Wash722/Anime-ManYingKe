import 'package:flutter/material.dart';
import '../services/bangumi_service.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import 'anime_category_page.dart';
import 'manga_page.dart'; 
import 'anime_detail_page.dart';
import 'home_search_page.dart';   
import 'manga_search_page.dart';  

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BangumiService _service = BangumiService();
  late Future<List<AnimeModel>> _dailyAnimeFuture;
  late Future<List<AnimeModel>> _mangaFuture;

  @override
  void initState() {
    super.initState();
    _dailyAnimeFuture = _service.fetchDailyAnime();
    _mangaFuture = _service.fetchPopularManga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildTopBar(),
              const SizedBox(height: 16),
              _buildBanner(), // Banner 现在会显示你的图片
              const SizedBox(height: 24),
              _buildSectionTitle("推荐番剧", "更多", onTapMore: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AnimeCategoryPage()));
              }),
              _buildHorizontalAnimeList(),
              const SizedBox(height: 8),
              _buildSectionTitle("推荐漫画", "更多", onTapMore: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const MangaPage()));
              }),
              _buildVerticalMangaGrid(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("签到成功！"))),
              child: SizedBox(
                width: 40, height: 40,
                child: Image.asset('assets/images/qd.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.check_circle_outline, size: 36, color: Colors.pink)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeSearchPage())),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD55066), width: 2.0),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(Icons.search, color: Color(0xFFD55066), size: 20),
                      SizedBox(width: 8),
                      Text("搜索番剧或漫画...", style: TextStyle(color: Colors.black38, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 【核心修改】将 Banner 改为加载你的本地图片
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          // 使用 Image.asset 来加载你的图片
          child: Image.asset(
            'assets/images/syxct.jpg', // 图片路径
            fit: BoxFit.cover, // 确保图片填满容器，可能会裁剪边缘
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalAnimeList() {
    return SizedBox(
      height: 160,
      child: FutureBuilder<List<AnimeModel>>(
        future: _dailyAnimeFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!.take(8).toList();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (ctx, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final anime = list[index];
              return AnimeCard(
                anime: anime, 
                width: 100,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailPage(anime: anime))),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVerticalMangaGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<AnimeModel>>(
        future: _mangaFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!.take(6).toList();
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.65, mainAxisSpacing: 12, crossAxisSpacing: 12),
            itemBuilder: (context, index) {
              final manga = list[index];
              return AnimeCard(
                anime: manga,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MangaSearchPage(
                    keyword: manga.displayName,
                    coverUrl: manga.imageUrl,
                    id: manga.id,
                  )));
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, {VoidCallback? onTapMore}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onTapMore,
            child: Row(
              children: [
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[500]),
              ],
            ),
          )
        ],
      ),
    );
  }
}