import 'dart:convert';

class ListNomor {
  int id;
  String nama;
  int number;
  ListNomor({
    this.id,
    this.nama,
    this.number,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'number': number,
    };
  }

  factory ListNomor.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ListNomor(
      id: map['id'],
      nama: map['nama'],
      number: map['number'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ListNomor.fromJson(String source) =>
      ListNomor.fromMap(json.decode(source));
}
