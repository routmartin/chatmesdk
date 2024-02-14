import '../../chat_room/model/pagination.dart';
import 'name.dart';

class GetRecommandStickerModel {
  GetRecommandStickerModel({
    this.data,
    this.pagination,
  });

  List<RecommandedStickerModel>? data;
  Pagination? pagination;

  factory GetRecommandStickerModel.fromJson(Map<String, dynamic> json) => GetRecommandStickerModel(
        data: json['data'] == null
            ? []
            : List<RecommandedStickerModel>.from(json['data']!.map((x) => RecommandedStickerModel.fromJson(x))),
        pagination: json['pagination'] == null ? null : Pagination.fromJson(json['pagination']),
      );
}

class RecommandedStickerModel {
  RecommandedStickerModel({
    this.id,
    this.name,
    this.description,
    this.useCount,
    this.thumbnail,
    this.isAdded,
  });

  String? id;
  List<Name>? name;
  List<Name>? description;
  int? useCount;
  String? thumbnail;
  bool? isAdded;

  factory RecommandedStickerModel.fromJson(Map<String, dynamic> json) => RecommandedStickerModel(
        id: json['_id'],
        name: json['name'] == null ? [] : List<Name>.from(json['name']!.map((x) => Name.fromJson(x))),
        description:
            json['description'] == null ? [] : List<Name>.from(json['description']!.map((x) => Name.fromJson(x))),
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
