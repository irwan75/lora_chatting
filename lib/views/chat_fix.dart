import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/models/read_chat.dart';
import 'package:lora_chatting/models/read_chat_details.dart';
import 'package:lora_chatting/resources/default_dialog.dart';
import 'package:lora_chatting/views/list_number.dart';

// ignore: must_be_immutable
class ChatFix extends StatelessWidget {
  int nilai;
  String name;
  BluetoothConnection connection;
  ChatFix({
    Key key,
    this.nilai,
    this.name,
    this.connection,
  }) : super(key: key);

  TextEditingController _formNumber = TextEditingController();
  TextEditingController _formPesan = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  Map<String, dynamic> getDataNumber = {};

  Map<String, dynamic> dataDummy = {
    'hasil': [
      {
        'pesan': "okeee",
        'rule': 1,
      },
      {
        'pesan': "okeee",
        'rule': 0,
      },
      {
        'pesan': "okeee",
        'rule': 1,
      },
      {
        'pesan': "okeee",
        'rule': 0,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Connectivity>(
      id: 'mainChat',
      init: Connectivity(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text((nilai == 0) ? "Pesan Baru" : "$name"),
            centerTitle: true,
          ),
          body: Container(
            child: Column(
              children: [
                (nilai == 0)
                    ? GetBuilder<Connectivity>(
                        id: 'dataNumber',
                        init: Connectivity(),
                        builder: (controller) {
                          return Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 20, bottom: 15),
                            child: TextFormField(
                              controller: _formNumber,
                              onTap: () async {
                                getDataNumber =
                                    await Get.to(ListNumber(kondisi: 1));
                                _formNumber = TextEditingController(
                                    text: getDataNumber['nama']);
                                controller.refreshDataNumber();
                              },
                              decoration: InputDecoration(
                                hintText: "Kepada:",
                                suffixIcon: Icon(Icons.person),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(),
                Expanded(
                  child: (nilai != 0)
                      ? FutureBuilder<List<ReadChatDetail>>(
                          future: controller.getPesan(nilai.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var hasil = snapshot.data;
                              return ListView.builder(
                                controller: listScrollController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: EdgeInsets.only(
                                    left: 12, right: 12, top: 12),
                                itemCount: hasil.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: (hasil[index].rule == 0)
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${hasil[index].tanggal}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 265,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: (hasil[index].rule == 0)
                                              ? Colors.blue
                                              : Colors.black12,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          "${hasil[index].chat}",
                                          style: TextStyle(
                                            color: (hasil[index].rule == 0)
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        )
                      : Container(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: TextFormField(
                              controller: _formPesan,
                              maxLines: 8,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText: "Tulis Pesanmu Disini",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            if (nilai == 0 &&
                                (_formNumber.text.isEmpty ||
                                    _formPesan.text.isEmpty)) {
                              defaultDialogCuctom("Nomor / Pesan Masih Kosong");
                            } else if (nilai != 0 && _formPesan.text.isEmpty) {
                              defaultDialogCuctom("Pesan Masih Kosong");
                            } else {
                              var result = await _sendMessage(
                                  _formPesan.text,
                                  (nilai == 0)
                                      ? getDataNumber['number'].toString()
                                      : nilai.toString());
                              if (result == 1) {
                                if (nilai == 0) {
                                  controller.addPesan(
                                      getDataNumber['number'].toString().trim(),
                                      _formPesan.text.trim(),
                                      0);
                                  nilai = getDataNumber['number'];
                                  name = getDataNumber['nama'];
                                  _formNumber.clear();
                                } else {
                                  controller.addPesan(nilai.toString().trim(),
                                      _formPesan.text.trim(), 0);
                                }
                                _formPesan.clear();
                                controller.refreshMainChat();
                                controller.refreshViewList();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int> _sendMessage(String text, String number) async {
    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(number + "~" + text + ""));
        await connection.output.allSent;

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        // print(listScrollController.position.toString());
        // listScrollController
        //     .jumpTo(listScrollController.position.maxScrollExtent);

        listScrollController.animateTo(
            listScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);

        return 1;
      } catch (e) {
        // Ignore error, but notify state
        // setState(() {});
        return 0;
      }
    }
  }
}
