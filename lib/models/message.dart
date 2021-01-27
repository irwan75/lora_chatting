import 'dart:convert';

class Message {
  int whom;
  String text;
  Message({
    this.whom,
    this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'whom': whom,
      'text': text,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Message(
      whom: map['whom'],
      text: map['text'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));
}
