import 'package:flutter/material.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final String _username = "漫音客";
  final int _level = 3;
  final int _currentExp = 1240;
  final int _nextLevelExp = 2500;

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFD55066);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/qd.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildLevelBadge(_level),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _currentExp / _nextLevelExp,
                                          backgroundColor: Colors.black12,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("经验 $_currentExp / $_nextLevelExp", style: const TextStyle(fontSize: 10, color: Colors.white70))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TopStat("12", "收藏"),
                      _TopStat("4", "关注"),
                      _TopStat("128", "足迹"),
                      _TopStat("3", "草稿"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              // 【核心修复】给这个 Column 加上 const
              child: const Column(
                children: [
                  _MenuItem(icon: Icons.cloud_download_outlined, title: "离线缓存"),
                  _Divider(),
                  _MenuItem(icon: Icons.history, title: "播放历史"),
                  _Divider(),
                  _MenuItem(icon: Icons.favorite_border, title: "我的追番"),
                  _Divider(),
                  _MenuItem(icon: Icons.palette_outlined, title: "主题设置", trailingText: "胭脂粉"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              // 【核心修复】给这个 Column 加上 const
              child: const Column(
                children: [
                  _MenuItem(icon: Icons.settings_outlined, title: "应用设置"),
                  _Divider(),
                  _MenuItem(icon: Icons.info_outline, title: "关于我们", trailingText: "v1.0.0"),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(int lv) {
    Color lvColor;
    switch (lv) {
      case 1: lvColor = Colors.grey; break;
      case 2: lvColor = Colors.green; break;
      case 3: lvColor = Colors.blue; break;
      case 4: lvColor = Colors.orange; break;
      case 5: lvColor = Colors.deepOrange; break;
      case 6: lvColor = Colors.red; break;
      default: lvColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: lvColor, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text("LV.$lv", style: TextStyle(color: lvColor, fontWeight: FontWeight.bold, fontSize: 10, fontStyle: FontStyle.italic)),
    );
  }
}

class _TopStat extends StatelessWidget {
  final String count;
  final String label;
  const _TopStat(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  const _MenuItem({required this.icon, required this.title, this.trailingText});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD55066)),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: () {},
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 50, endIndent: 16, color: Colors.black12);
  }
}