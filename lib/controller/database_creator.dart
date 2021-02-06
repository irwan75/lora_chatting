import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database db;

class DatabaseCreator {
  Future<void> createTableChatting(Database db) async {
    final master_numberSQL = '''CREATE TABLE master_number
    (
      id_number INTEGER PRIMARY KEY,
      nama VARCHAR(30),
      number BIGINT UNIQUE
    )''';

    final data_pesanSQL = '''CREATE TABLE data_pesan
    (
      id_chat INTEGER PRIMARY KEY,
      number BIGINT,
      chat TEXT,
      tanggal DATETIME,
      rule INT,
      FOREIGN KEY(number) REFERENCES master_number(number)
    )''';

    await db.execute(master_numberSQL);
    await db.execute(data_pesanSQL);
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
    final path = await getDatabasePath('lora_chatin');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTableChatting(db);
  }
}
