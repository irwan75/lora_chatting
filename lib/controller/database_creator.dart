import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database db;

class DatabaseCreator {
  Future<void> createTableChatting(Database db) async {
    final tb_numberSQL = '''CREATE TABLE tb_number
    (
      id_number INTEGER PRIMARY KEY,
      number BIGINT
    )''';

    final tb_chatSQL = '''CREATE TABLE tb_chat
    (
      id_chat INTEGER PRIMARY KEY,
      number BIGINT,
      chat TEXT,
      tanggal DATETIME,
      rule INT,
      FOREIGN KEY(number) REFERENCES tb_number(number)
    )''';

    await db.execute(tb_numberSQL);
    await db.execute(tb_chatSQL);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (await Directory(dirname(path)).exists()) {
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('lora_chatting');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTableChatting(db);
  }
}
