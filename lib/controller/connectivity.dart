import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:lora_chatting/controller/database_creator.dart';
import 'package:lora_chatting/models/list_nomor.dart';
import 'package:lora_chatting/models/read_chat.dart';
import 'package:lora_chatting/models/read_chat_details.dart';
import 'package:lora_chatting/views/list_number.dart';

class Connectivity extends GetxController {
  BluetoothDevice device;
  String nilai_nilai;
  String number;

  void setNumber(String val) {
    number = val;
    update();
  }

  void setUpdate() {
    update();
  }

  void setBluetoothDevice(BluetoothDevice device) {
    this.device = device;
  }

  void setNilai(String nilai) {
    this.nilai_nilai = nilai;
    update();
  }

  Future<List<ReadChat>> getPesanMain() async {
    final sql =
        '''SELECT DISTINCT master_number.number, (SELECT DISTINCT chat FROM data_pesan WHERE data_pesan.number=master_number.number ORDER BY data_pesan.id_chat DESC) as chat, (SELECT DISTINCT tanggal FROM data_pesan WHERE data_pesan.number=master_number.number ORDER BY data_pesan.id_chat DESC) as tanggal from master_number, data_pesan''';

    final data = await db.rawQuery(sql);

    List<ReadChat> penyimpanan = [];

    for (int i = 0; i < data.length; i++) {
      penyimpanan.add(
        new ReadChat(
          "${data[i]['number']}",
          data[i]['chat'],
          data[i]['tanggal'],
        ),
      );
    }

    return penyimpanan;
  }

  Future<int> addNumber(String nama, String number) async {
    final sql = '''INSERT INTO master_number
    (
      nama,
      number
    )
    VALUES ('$nama',$number)''';
    final result = await db.rawInsert(sql);
    return result;
  }

  Future<int> addPesan(String number, String chat, int rule) async {
    final sql = '''INSERT INTO data_pesan
    (
      number,
      chat,
      tanggal,
      rule
    )
    VALUES (${number.trim()},'${chat.trim()}',datetime('now'),$rule)''';
    final result = await db.rawInsert(sql);
    update();
    return result;
  }

  Future<List<ReadChatDetail>> getPesan(String number) async {
    final sql = '''SELECT * FROM data_pesan
    WHERE number = $number''';

    final data = await db.rawQuery(sql);

    List<ReadChatDetail> penyimpanan = [];

    for (int i = 0; i < data.length; i++) {
      // final todo = ReadChat.fromMap(data[i]);
      penyimpanan.add(
        new ReadChatDetail(
          data[i]['number'],
          data[i]['chat'],
          data[i]['tanggal'],
          data[i]['rule'],
        ),
      );
    }

    return penyimpanan;
  }

  Future<List<ListNomor>> getNumberDevice() async {
    final sql = '''SELECT * FROM master_number''';

    final data = await db.rawQuery(sql);

    List<ListNomor> penyimpanan = [];

    for (int i = 0; i < data.length; i++) {
      // final todo = ReadChat.fromMap(data[i]);
      penyimpanan.add(
        new ListNomor(
          id: data[i]['id'],
          nama: data[i]['nama'],
          number: data[i]['number'],
        ),
      );
      // penyimpanan.add(
      //   new ListNumber(

      //   ),
      // );
    }

    return penyimpanan;
  }
}
