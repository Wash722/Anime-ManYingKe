class MangaModel {
  final String id;
  final String title;
  final String coverUrl;

  MangaModel({
    required this.id,
    required this.title,
    required this.coverUrl,
  });

  factory MangaModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    
    String titleText = '无标题';
    if (attributes['title'] != null) {
      titleText = attributes['title']['zh'] 
        ?? attributes['title']['en'] 
        ?? attributes['title']['ja']
        ?? attributes['title'].values.first ?? '未知';
    }

    String fileName = '';
    if (json['relationships'] != null) {
      for (var rel in json['relationships']) {
        if (rel['type'] == 'cover_art' && rel['attributes'] != null) {
          fileName = rel['attributes']['fileName'];
          break;
        }
      }
    }

    String finalCoverUrl = '';
    if (fileName.isNotEmpty) {
      finalCoverUrl = 'https://uploads.mangadex.org/covers/${json['id']}/$fileName.256.jpg';
    }

    return MangaModel(
      id: json['id'],
      title: titleText,
      coverUrl: finalCoverUrl,
    );
  }
}