class AnimeModel {
  final int id;
  final String name;
  final String nameCn;
  final String imageUrl;
  final double? score;
  final String type;
  final String airDate;

  AnimeModel({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.imageUrl,
    this.score,
    this.type = 'anime',
    this.airDate = '',
  });

  int? get releaseYear {
    if (airDate.length >= 4) {
      return int.tryParse(airDate.substring(0, 4));
    }
    return null;
  }

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['images'] != null && json['images'] is Map) {
      img = json['images']['large'] ?? json['images']['common'] ?? json['images']['medium'] ?? '';
    }

    String typeStr = json['type_tag'] ?? 'anime';
    if (json['type'] != null) {
      int apiType = json['type'];
      if (apiType == 1) {
        typeStr = 'manga';
      } else if (apiType == 2) {
        typeStr = 'anime';
      }
    }

    return AnimeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '无名',
      nameCn: json['name_cn'] ?? '',
      imageUrl: img,
      score: (json['rating'] != null && json['rating']['score'] != null)
          ? (json['rating']['score'] as num).toDouble()
          : 0.0,
      type: typeStr,
      airDate: json['air_date'] ?? '',
    );
  }

  String get displayName => (nameCn.isNotEmpty) ? nameCn : name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_cn': nameCn,
      'imageUrl': imageUrl,
      'rating': {'score': score},
      'type_tag': type,
      'air_date': airDate,
    };
  }

  AnimeModel copyWith({String? type}) {
    return AnimeModel(
      id: id,
      name: name,
      nameCn: nameCn,
      imageUrl: imageUrl,
      score: score,
      airDate: airDate,
      type: type ?? this.type,
    );
  }
}