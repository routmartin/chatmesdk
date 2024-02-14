// To parse this JSON data, do
//
//     final addStickerResponseModel = addStickerResponseModelFromJson(jsonString);

import 'dart:convert';

AddStickerResponseModel addStickerResponseModelFromJson(String str) =>
    AddStickerResponseModel.fromJson(json.decode(str));

String addStickerResponseModelToJson(AddStickerResponseModel data) => json.encode(data.toJson());

class AddStickerResponseModel {
  AddStickerResponseModel({
    this.data,
  });

  Data? data;

  factory AddStickerResponseModel.fromJson(Map<String, dynamic> json) => AddStickerResponseModel(
        data: json['data'] == null ? null : Data.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
      };
}

class Data {
  Data({
    this.group,
    this.user,
    this.isDeleted,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.dataId,
    this.isAdded = false,
  });

  String? group;
  String? user;
  bool? isDeleted;
  bool isAdded;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? dataId;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        group: json['group'],
        user: json['user'],
        isDeleted: json['isDeleted'],
        id: json['_id'],
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']),
        v: json['__v'],
        dataId: json['id'],
      );

  Map<String, dynamic> toJson() => {
        'group': group,
        'user': user,
        'isDeleted': isDeleted,
        '_id': id,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': v,
        'id': dataId,
      };
}
