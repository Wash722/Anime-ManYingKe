import 'package:flutter/material.dart';
import '../models/manga_model.dart';
import '../services/mangadex_service.dart';
import 'manga_reader_page.dart';

class MangaDetailPage extends StatefulWidget {
  final MangaModel manga;

  const MangaDetailPage({super.key, required this.manga});

  @override
  State<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  final MangaDexService _service = MangaDexService();
  late Future<List<Map<String, dynamic>>> _chaptersFuture;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _service.fetchChapters(widget.manga.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.manga.title)),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    widget.manga.coverUrl, 
                    width: 80, 
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(width: 80, height: 120, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("阅读提示：", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("列表包含多种语言资源。", style: TextStyle(color: Colors.grey)),
                      Text("MangaDex 图片在海外，加载稍慢请耐心等待。", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _chaptersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('加载失败: ${snapshot.error}'));
                }
                
                final chapters = snapshot.data ?? [];
                if (chapters.isEmpty) {
                  return const Center(child: Text('暂无章节或无可用资源'));
                }

                return ListView.builder(
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return ListTile(
                      title: Text(chapter['title']),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MangaReaderPage(
                              chapters: chapters,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}