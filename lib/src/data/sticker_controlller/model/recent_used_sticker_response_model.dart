import 'dart:convert';

import '../../chat_room/model/pagination.dart';

RecentUsedStickerResponseModel recentUsedStickerResponseModelFromJson(String str) =>
    RecentUsedStickerResponseModel.fromJson(json.decode(str));

class RecentUsedStickerResponseModel {
  RecentUsedStickerResponseModel({
    this.data,
    this.pagination,
  });

  List<RecentUsedStickers>? data;
  Pagination? pagination;

  factory RecentUsedStickerResponseModel.fromJson(Map<String, dynamic> json) => RecentUsedStickerResponseModel(
        data: json['data'] == null
            ? []
            : List<RecentUsedStickers>.from(json['data']!.map((x) => RecentUsedStickers.fromJson(x))),
        pagination: json['pagination'] == null ? null : Pagination.fromJson(json['pagination']),
      );
}

class RecentUsedStickers {
  RecentUsedStickers({
    this.id,
    this.image,
    this.emoji,
  });

  String? id;
  String? image;
  String? emoji;

  factory RecentUsedStickers.fromJson(Map<String, dynamic> json) => RecentUsedStickers(
        id: json['stickerId'],
        image: json['image'],
        emoji: json['emoji'],
      );
}
