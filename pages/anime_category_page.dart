import 'package:flutter/material.dart';
import '../services/bangumi_service.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import 'anime_detail_page.dart';

class AnimeCategoryPage extends StatefulWidget {
  const AnimeCategoryPage({super.key});

  @override
  State<AnimeCategoryPage> createState() => _AnimeCategoryPageState();
}

class _AnimeCategoryPageState extends State<AnimeCategoryPage> {
  final BangumiService _service = BangumiService();
  final Color _themeColor = const Color(0xFFD55066);

  final List<String> _types = [
    "全部类型", "热血", "恋爱", "校园", "百合", "科幻", "奇幻", 
    "战斗", "搞笑", "日常", "治愈", "致郁", "机战", 
    "悬疑", "推理", "运动", "音乐", "后宫", "异世界"
  ];
  final List<String> _years = [
    "全部年份", "2025", "2024", "2023", "2022", "2021", "2020", "2019", "2010年代", "2000年代"
  ];
  final List<String> _sorts = ["综合排序", "最新开播", "全站最热", "评分最高"];

  String _selectedType = "全部类型";
  String _selectedYear = "全部年份";
  String _selectedSort = "综合排序";

  List<AnimeModel> _animeList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      List<AnimeModel> rawList;

      if (_selectedType == "全部类型") {
        rawList = await _service.fetchDailyAnime();
      } else {
        rawList = await _service.searchSubject(_selectedType, type: 2);
      }
      
      List<AnimeModel> filteredList = rawList;

      if (_selectedYear != "全部年份") {
        if (_selectedYear.contains("年代")) {
          int startYear = int.parse(_selectedYear.substring(0, 4));
          int endYear = startYear + 9;
          filteredList = filteredList.where((anime) {
            final year = anime.releaseYear;
            return year != null && year >= startYear && year <= endYear;
          }).toList();
        } else {
          int year = int.parse(_selectedYear);
          filteredList = filteredList.where((anime) => anime.releaseYear == year).toList();
        }
      }

      if (_selectedSort == "评分最高") {
        filteredList.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
      } else if (_selectedSort == "最新开播") {
        filteredList.sort((a, b) {
          final dateA = DateTime.tryParse(a.airDate);
          final dateB = DateTime.tryParse(b.airDate);
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
      }

      if (mounted) {
        setState(() {
          _animeList = filteredList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { 
          _animeList = []; 
          _isLoading = false; 
        });
      }
    }
  }

  void _onFilterChanged() {
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("番剧索引", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, 4), blurRadius: 4)
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterRow(_types, _selectedType, (val) {
                  setState(() => _selectedType = val);
                  _onFilterChanged();
                }),
                const SizedBox(height: 8),
                _buildFilterRow(_years, _selectedYear, (val) {
                  setState(() => _selectedYear = val);
                  _onFilterChanged();
                }),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _sorts.map((sort) {
                      final bool isSelected = sort == _selectedSort;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedSort = sort);
                          _onFilterChanged();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 24),
                          decoration: isSelected ? BoxDecoration(
                            border: Border(bottom: BorderSide(color: _themeColor, width: 2))
                          ) : null,
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            sort,
                            style: TextStyle(
                              color: isSelected ? _themeColor : Colors.grey[500],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _themeColor))
                : _animeList.isEmpty
                    ? const Center(child: Text("暂无符合条件的番剧"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.65,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _animeList.length,
                        itemBuilder: (context, index) {
                          final anime = _animeList[index];
                          return AnimeCard(
                            anime: anime,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnimeDetailPage(anime: anime),
                                ),
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

  Widget _buildFilterRow(List<String> options, String currentVal, Function(String) onSelect) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final String option = options[index];
          final bool isSelected = option == currentVal;

          return GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _themeColor.withValues(alpha: 0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                   color: isSelected ? _themeColor : Colors.transparent
                )
              ),
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? _themeColor : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}