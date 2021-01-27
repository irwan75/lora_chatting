import 'dart:convert';

class ReadChatDetail {
  int number;
  String chat;
  String tanggal;
  int rule;

  ReadChatDetail(
    this.number,
    this.chat,
    this.tanggal,
    this.rule,
  );

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'chat': chat,
      'tanggal': tanggal,
      'rule': rule,
    };
  }

  factory ReadChatDetail.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ReadChatDetail(
      map['number'],
      map['chat'],
      map['tanggal'],
      map['rule'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ReadChatDetail.fromJson(String source) =>
      ReadChatDetail.fromMap(json.decode(source));
}
