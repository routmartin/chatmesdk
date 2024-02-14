import 'dart:convert';

class Sticker {
  String? id;
  String? emoji;
  int? useCount;
  String? image;

  Sticker({this.id, this.emoji, this.useCount, this.image});

  factory Sticker.fromMap(Map<String, dynamic> data) => Sticker(
        id: data['_id'] as String?,
        emoji: data['emoji'] as String?,
        useCount: data['useCount'] as int?,
        image: data['image'] as String?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'emoji': emoji,
        'useCount': useCount,
        'image': image,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Sticker].
  factory Sticker.fromJson(String data) {
    return Sticker.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Sticker] to a JSON string.
  String toJson() => json.encode(toMap());
}
