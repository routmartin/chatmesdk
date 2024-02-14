import 'dart:convert';

ViewStickersResponseModel viewStickersResponseModelFromJson(String str) =>
    ViewStickersResponseModel.fromJson(json.decode(str));

String viewStickersResponseModelToJson(ViewStickersResponseModel data) => json.encode(data.toJson());

class ViewStickersResponseModel {
  ViewStickersResponseModel({
    this.data,
  });

  Data? data;

  factory ViewStickersResponseModel.fromJson(Map<String, dynamic> json) => ViewStickersResponseModel(
        data: json['data'] == null ? null : Data.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
      };
}

class Data {
  Data({
    this.id,
    this.name,
    this.description,
    this.thumbnail,
    this.stickers,
    this.isAdded,
  });

  String? id;
  List<Description>? name;
  List<Description>? description;
  String? thumbnail;
  List<Sticker>? stickers;
  bool? isAdded;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json['_id'],
        name: json['name'] == null ? [] : List<Description>.from(json['name']!.map((x) => Description.fromJson(x))),
        description: json['description'] == null
            ? []
            : List<Description>.from(json['description']!.map((x) => Description.fromJson(x))),
        thumbnail: json['thumbnail'],
        stickers: json['stickers'] == null ? [] : List<Sticker>.from(json['stickers']!.map((x) => Sticker.fromJson(x))),
        isAdded: json['isAdded'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name == null ? [] : List<dynamic>.from(name!.map((x) => x.toJson())),
        'description': description == null ? [] : List<dynamic>.from(description!.map((x) => x.toJson())),
        'thumbnail': thumbnail,
        'stickers': stickers == null ? [] : List<dynamic>.from(stickers!.map((x) => x.toJson())),
        'isAdded': isAdded,
      };
}

class Description {
  Description({
    this.locale,
    this.value,
  });

  String? locale;
  String? value;

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        locale: json['locale'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'locale': locale,
        'value': value,
      };
}

class Sticker {
  Sticker({
    this.id,
    this.useCount,
    this.image,
    this.emoji,
  });

  String? id;
  int? useCount;
  String? image;
  String? emoji;

  factory Sticker.fromJson(Map<String, dynamic> json) => Sticker(
        id: json['_id'],
        useCount: json['useCount'],
        image: json['image'],
        emoji: json['emoji'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'useCount': useCount,
        'image': image,
        'emoji': emoji,
      };
}
