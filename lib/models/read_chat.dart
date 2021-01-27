class ReadChat {
  String number;
  String chat;
  String tanggal;
  ReadChat(
    this.number,
    this.chat,
    this.tanggal,
  );

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'chat': chat,
      'tanggal': tanggal,
    };
  }

  factory ReadChat.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ReadChat(
      map['number'],
      map['chat'],
      map['tanggal'],
    );
  }
}
