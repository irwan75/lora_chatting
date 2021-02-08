import 'dart:convert';

class ReadChat {
  String nama;
  String number;
  String chat;
  String tanggal;
  ReadChat({
    this.nama,
    this.number,
    this.chat,
    this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'number': number,
      'chat': chat,
      'tanggal': tanggal,
    };
  }

  factory ReadChat.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ReadChat(
      nama: map['nama'],
      number: map['number'],
      chat: map['chat'],
      tanggal: map['tanggal'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ReadChat.fromJson(String source) =>
      ReadChat.fromMap(json.decode(source));
}
