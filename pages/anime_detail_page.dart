import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/anime_model.dart';
import '../services/storage_service.dart';
import '../services/jinying_service.dart';

class AnimeDetailPage extends StatefulWidget {
  final AnimeModel anime;
  const AnimeDetailPage({super.key, required this.anime});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final StorageService _storage = StorageService();
  final JinyingService _jinyingService = JinyingService();
  
  late final Player _player = Player();
  late final VideoController _videoController;

  List<Map<String, String>> _episodeList = [];
  int _currentEpisodeIndex = 0;
  bool _isLoadingVideo = true;
  String _loadingMessage = "视频加载中..."; 

  final int _inlineEpisodeCount = 10;
  
  // 【核心修复】_playerContext 已被移除

  @override
  void initState() {
    super.initState();
    _videoController = VideoController(_player);
    _storage.addHistory(widget.anime);
    _searchAndPlay();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _searchAndPlay() async {
    int? vodId = await _jinyingService.searchVodId(
      widget.anime.displayName,
      originalName: widget.anime.name,
    );

    if (vodId == null) {
      _onVideoError("加载失败: 未找到《${widget.anime.displayName}》的相关资源");
      return;
    }

    if (!mounted) return;
    final episodes = await _jinyingService.fetchPlayableEpisodes(vodId);
    
    if (episodes.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _episodeList = episodes;
        _currentEpisodeIndex = 0;
      });
      await _initializePlayer(episodes[0]['url']!);
    } else {
      _onVideoError("加载失败: 未能获取到剧集列表");
    }
  }

  Future<void> _initializePlayer(String finalUrl) async {
    if (!mounted) return;
    setState(() {
      _isLoadingVideo = true;
      _loadingMessage = "视频加载中...";
    });
    
    try {
      await _player.open(Media(finalUrl), play: true);
      if (mounted) {
        setState(() => _isLoadingVideo = false);
      }
    } catch (e) {
      _onVideoError("播放失败: 视频源无效或网络超时");
    }
  }

  void _onVideoError(String message) {
    if (mounted) {
      setState(() {
        _isLoadingVideo = false;
        _loadingMessage = message;
      });
    }
  }

  void _changeEpisode(int index) {
    if (index >= 0 && index < _episodeList.length) {
      if (!mounted) return;
      setState(() => _currentEpisodeIndex = index);
      _initializePlayer(_episodeList[index]['url']!);
    }
  }
  
  void _showAllEpisodes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("选择集数 (${_episodeList.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 2.0, mainAxisSpacing: 12, crossAxisSpacing: 12,
                  ),
                  itemCount: _episodeList.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentEpisodeIndex;
                    return GestureDetector(
                      onTap: () {
                        _changeEpisode(index);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD55066).withValues(alpha: 0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? const Color(0xFFD55066) : Colors.grey[300]!),
                        ),
                        child: Text(
                          _episodeList[index]['name']!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFD55066) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFD55066);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _isLoadingVideo
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              const CircularProgressIndicator(color: Colors.white), 
                              const SizedBox(height: 16), 
                              Text(
                                _loadingMessage,
                                style: TextStyle(
                                  color: _loadingMessage.contains("失败")
                                      ? Colors.red[300]!
                                      : Colors.white70,
                                  fontSize: 12
                                ), 
                                textAlign: TextAlign.center,
                              )
                            ]
                          ),
                        )
                      )
                    : Video(controller: _videoController),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.anime.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("选集", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_episodeList.length > _inlineEpisodeCount)
                        GestureDetector(
                          onTap: _showAllEpisodes,
                          child: Row(
                            children: [
                              Text("更多", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _episodeList.isEmpty
                      // 【核心修改】把“暂无选集信息”改成更准确的提示
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10), 
                            child: Text(
                              _isLoadingVideo ? "正在获取剧集..." : "加载失败", 
                              style: const TextStyle(color: Colors.grey)
                            )
                          )
                        )
                      : SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _episodeList.length > _inlineEpisodeCount ? _inlineEpisodeCount : _episodeList.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _currentEpisodeIndex;
                              return GestureDetector(
                                onTap: () => _changeEpisode(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  margin: const EdgeInsets.only(right: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? themeColor.withValues(alpha: 0.1) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _episodeList[index]['name']!,
                                    style: TextStyle(
                                      color: isSelected ? themeColor : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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