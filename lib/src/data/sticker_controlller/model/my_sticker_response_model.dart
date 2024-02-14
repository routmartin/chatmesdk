import 'dart:convert';
import '../../chat_room/model/pagination.dart';
import 'name.dart';

ListMyStickerResponseModel listMyStickerResponseModelFromJson(String str) =>
    ListMyStickerResponseModel.fromJson(json.decode(str));

class ListMyStickerResponseModel {
  ListMyStickerResponseModel({
    this.data,
    this.pagination,
  });

  List<MyStickerModel>? data;
  Pagination? pagination;

  factory ListMyStickerResponseModel.fromJson(Map<String, dynamic> json) => ListMyStickerResponseModel(
        data:
            json['data'] == null ? [] : List<MyStickerModel>.from(json['data']!.map((x) => MyStickerModel.fromJson(x))),
        pagination: json['pagination'] == null ? null : Pagination.fromJson(json['pagination']),
      );
}

class MyStickerModel {
  MyStickerModel({
    this.id,
    this.name,
    this.thumbnail,
    this.stickers,
    this.stickergroupId,
    this.description,
  });

  String? id;
  List<Name>? name;
  String? thumbnail;
  List<Name>? description;
  String? stickergroupId;
  List<Sticker>? stickers;

  factory MyStickerModel.fromJson(Map<String, dynamic> json) => MyStickerModel(
        id: json['_id'],
        description:
            json['description'] == null ? [] : List<Name>.from(json['description']!.map((x) => Name.fromJson(x))),
        stickergroupId: json['stickergroupId'],
        name: json['name'] == null ? [] : List<Name>.from(json['name']!.map((x) => Name.fromJson(x))),
        thumbnail: json['thumbnail'],
        stickers: json['stickers'] == null ? [] : List<Sticker>.from(json['stickers']!.map((x) => Sticker.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'stickergroupId': stickergroupId,
        '_description': description == null ? [] : List<dynamic>.from(description!.map((x) => x.toJson())),
        'name': name == null ? [] : List<dynamic>.from(name!.map((x) => x.toJson())),
        'thumbnail': thumbnail,
        'stickers': stickers == null ? [] : List<dynamic>.from(stickers!.map((x) => x.toJson())),
      };
}

// class Name {
//   Name({
//     this.locale,
//     this.value,
//   });

//   Locale? locale;
//   String? value;

//   factory Name.fromJson(Map<String, dynamic> json) => Name(
//         locale: localeValues.map[json['locale']]!,
//         value: json['value'],
//       );

//   Map<String, dynamic> toJson() => {
//         'locale': localeValues.reverse[locale],
//         'value': value,
//       };
// }

class Sticker {
  Sticker({
    this.id,
    this.image,
    this.emoji,
  });

  String? id;
  String? image;
  String? emoji;

  factory Sticker.fromJson(Map<String, dynamic> json) => Sticker(
        id: json['_id'],
        image: json['image'],
        emoji: json['emoji'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'image': image,
        'emoji': emoji,
      };
}
