import 'dart:convert';

class MarkAsReadResponseModel {
  String? id;
  String? type;
  bool? isOfficial;
  String? name;
  int? unreadCount;

  MarkAsReadResponseModel({
    this.id,
    this.type,
    this.isOfficial,
    this.name,
    this.unreadCount,
  });

  factory MarkAsReadResponseModel.fromMap(Map<String, dynamic> data) {
    return MarkAsReadResponseModel(
      id: data['_id'] as String?,
      type: data['type'] as String?,
      isOfficial: data['isOfficial'] as bool?,
      name: data['name'] as String?,
      unreadCount: data['unreadCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'type': type,
        'isOfficial': isOfficial,
        'name': name,
        'unreadCount': unreadCount,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MarkAsReadResponseModel].
  factory MarkAsReadResponseModel.fromJson(String data) {
    return MarkAsReadResponseModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MarkAsReadResponseModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
