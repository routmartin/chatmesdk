class Sticker {
  final String? url;
  final String? emoji;
  final String? groupId;
  Sticker(this.url, this.emoji, this.groupId);

  factory Sticker.fromMap(Map<String, dynamic> map) {
    return Sticker(
      map['url'] != null ? map['url'] as String : null,
      map['emoji'] != null ? map['emoji'] as String : null,
      map['groupId'] != null ? map['groupId'] as String : null,
    );
  }
}
