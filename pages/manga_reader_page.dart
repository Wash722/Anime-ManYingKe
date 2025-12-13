import 'package:flutter/material.dart';
import '../services/mangadex_service.dart';

class MangaReaderPage extends StatefulWidget {
  final List<Map<String, dynamic>> chapters;
  final int initialIndex;

  const MangaReaderPage({
    super.key, 
    required this.chapters, 
    required this.initialIndex
  });

  @override
  State<MangaReaderPage> createState() => _MangaReaderPageState();
}

class _MangaReaderPageState extends State<MangaReaderPage> {
  final MangaDexService _service = MangaDexService();
  final ScrollController _scrollController = ScrollController();
  
  late int _currentIndex;
  late Future<List<String>> _imagesFuture;
  
  bool _showMenu = true; 

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadChapter();
  }

  void _loadChapter() {
    final chapterId = widget.chapters[_currentIndex]['id'].toString();
    setState(() {
      _imagesFuture = _service.fetchChapterImages(chapterId);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _prevChapter() {
    if (_currentIndex < widget.chapters.length - 1) {
      setState(() => _currentIndex++);
      _loadChapter();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("已经是第一话了")));
    }
  }

  void _nextChapter() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadChapter();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("已经是最新一话了")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = widget.chapters[_currentIndex];
    const Color themeColor = Color(0xFFD55066);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showMenu ? AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentChapter['title'], style: const TextStyle(fontSize: 14)),
            Text("(${widget.chapters.length - _currentIndex}/${widget.chapters.length})", style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
      ) : null,
      
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showMenu = !_showMenu),
            child: FutureBuilder<List<String>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: themeColor));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('加载失败: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                
                final imageUrls = snapshot.data ?? [];
                
                return ListView.builder(
                  controller: _scrollController,
                  cacheExtent: 1500, 
                  itemCount: imageUrls.length + 1,
                  itemBuilder: (context, index) {
                    if (index == imageUrls.length) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: ElevatedButton(
                          onPressed: _nextChapter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("点击跳转下一话"),
                        ),
                      );
                    }

                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, loading) {
                        if (loading == null) return child;
                        return Container(
                          height: 300, 
                          color: Colors.grey[900],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loading.expectedTotalBytes != null
                                  ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
                                  : null,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 200,
                        color: Colors.grey[900],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showMenu ? 0 : -80,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                border: const Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: _currentIndex < widget.chapters.length - 1 ? _prevChapter : null,
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    label: const Text("上一话", style: TextStyle(color: Colors.white)),
                  ),
                  Text("${widget.chapters.length - _currentIndex} / ${widget.chapters.length}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  TextButton.icon(
                    onPressed: _currentIndex > 0 ? _nextChapter : null,
                    label: const Text("下一话", style: TextStyle(color: themeColor)),
                    icon: const Icon(Icons.skip_next, color: themeColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}