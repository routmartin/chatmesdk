// To parse this JSON data, do
//
//     final getAllAvailableStickerResponseModel = getAllAvailableStickerResponseModelFromJson(jsonString);

import 'dart:convert';

import '../../chat_room/model/pagination.dart';

GetAllAvailableStickerResponseModel getAllAvailableStickerResponseModelFromJson(String str) =>
    GetAllAvailableStickerResponseModel.fromJson(json.decode(str));

class GetAllAvailableStickerResponseModel {
  GetAllAvailableStickerResponseModel({
    this.data,
    this.pagination,
  });

  List<AllAvailableStickers>? data;
  Pagination? pagination;

  factory GetAllAvailableStickerResponseModel.fromJson(Map<String, dynamic> json) =>
      GetAllAvailableStickerResponseModel(
        data: json['data'] == null
            ? []
            : List<AllAvailableStickers>.from(json['data']!.map((x) => AllAvailableStickers.fromJson(x))),
        pagination: json['pagination'] == null ? null : Pagination.fromJson(json['pagination']),
      );
}

class AllAvailableStickers {
  AllAvailableStickers({
    this.id,
    this.category,
    this.result,
  });

  String? id;
  List<StickerCategoryOrResultName>? category;
  List<Result>? result;

  factory AllAvailableStickers.fromJson(Map<String, dynamic> json) => AllAvailableStickers(
        id: json['_id'],
        category: json['category'] == null
            ? []
            : List<StickerCategoryOrResultName>.from(
                json['category']!.map((x) => StickerCategoryOrResultName.fromJson(x))),
        result: json['result'] == null ? [] : List<Result>.from(json['result']!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'category': category == null ? [] : List<dynamic>.from(category!.map((x) => x.toJson())),
        'result': result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class StickerCategoryOrResultName {
  StickerCategoryOrResultName({
    this.value,
    this.locale,
  });

  String? value;
  Locale? locale;

  factory StickerCategoryOrResultName.fromJson(Map<String, dynamic> json) => StickerCategoryOrResultName(
        value: json['value'],
        locale: localeValues.map[json['locale']]!,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        'locale': localeValues.reverse[locale],
      };
}

enum Locale { EN_US, ZH_CN }

final localeValues = EnumValues({'en-US': Locale.EN_US, 'zh-CN': Locale.ZH_CN});

class Result {
  Result({
    this.id,
    this.name,
    this.description,
    this.useCount,
    this.thumbnail,
    this.isAdded,
  });

  String? id;
  List<StickerCategoryOrResultName>? name;
  List<StickerCategoryOrResultName>? description;
  int? useCount;
  String? thumbnail;
  bool? isAdded;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json['_id'],
        name: json['name'] == null
            ? []
            : List<StickerCategoryOrResultName>.from(json['name']!.map((x) => StickerCategoryOrResultName.fromJson(x))),
        description: json['description'] == null
            ? []
            : List<StickerCategoryOrResultName>.from(
                json['description']!.map((x) => StickerCategoryOrResultName.fromJson(x))),
        useCount: json['useCount'],
        thumbnail: json['thumbnail'],
        isAdded: json['isAdded'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name == null ? [] : List<dynamic>.from(name!.map((x) => x.toJson())),
        'description': description,
        'useCount': useCount,
        'thumbnail': thumbnail,
        'isAdded': isAdded,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
