import 'dart:convert';

class Name {
  String? value;
  String? locale;
  String? id;

  Name({this.value, this.locale, this.id});

  factory Name.fromMap(Map<String, dynamic> data) => Name(
        value: data['value'] as String?,
        locale: data['locale'] as String?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'value': value,
        'locale': locale,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Name].
  factory Name.fromJson(String data) {
    return Name.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Name] to a JSON string.
  String toJson() => json.encode(toMap());
}
