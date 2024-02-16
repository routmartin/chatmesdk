class AttachmentModel {
  String? user;
  String? url;
  String? originalName;
  String? fileType;
  String? fileSize;
  String? mimeType;
  DateTime? createdAt;
  String? id;
  int? v;
  bool? hasQrcode;
  String? uploadPath = '';
  int? uploadPercentage;
  bool? isDropped;

  AttachmentModel({
    this.user,
    this.url,
    this.originalName,
    this.fileType,
    this.fileSize,
    this.mimeType,
    this.createdAt,
    this.id,
    this.v,
    this.hasQrcode,
    this.uploadPath,
    this.uploadPercentage,
    this.isDropped,
  });

  @override
  String toString() {
    return 'AttachmentModel(user: $user, url: $url, originalName: $originalName, fileType: $fileType, fileSize: $fileSize, mimeType: $mimeType, createdAt: $createdAt, id: $id, v: $v)';
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> data) {
    return AttachmentModel(
        user: data['user'] as String?,
        url: Uri.encodeFull(data['url'] ?? ''),
        originalName: data['originalName'] as String?,
        fileType: data['fileType'] as String?,
        fileSize: data['fileSize'] as String?,
        mimeType: data['mimeType'] as String?,
        createdAt: data['createdAt'] == null ? null : DateTime.parse(data['createdAt'] as String),
        id: data['_id'] as String?,
        v: data['__v'] as int?,
        isDropped: data['isDropped'] ?? false);
  }
}
