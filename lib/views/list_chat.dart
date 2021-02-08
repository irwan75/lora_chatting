import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:lora_chatting/models/storage.dart';
import 'package:lora_chatting/views/chat.dart';
import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/views/chat_fix.dart';
import 'package:lora_chatting/views/list_number.dart';
import 'package:lora_chatting/views/model_chat.dart';
import 'package:lora_chatting/models/read_chat.dart';

class ListChat extends StatelessWidget {
  List<int> selectedList = [];

  bool kondisiSelected = false;

  BluetoothConnection connection;

  Future<int> bluetoothConnect() async {
    try {
      await Future.delayed(Duration(seconds: 2)).then((value) => {});
      connection =
          await BluetoothConnection.toAddress(Storage.getAddressPref());
      print('Connected to the device');

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
      });

      // connection.input.listen((Uint8List data) {
      //   print('Data incoming: ${ascii.decode(data)}');
      //   connection.output.add(data); // Sending data

      //   if (ascii.decode(data).contains('!')) {
      //     connection.finish(); // Closing connection
      //     print('Disconnecting by local host');
      //   }
      // }).onDone(() {
      //   print('Disconnected by remote request');
      // });
      return 1;
    } catch (exception) {
      print('Cannot connect, exception occured');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Connectivity>(
      id: 'refreshConnection',
      init: Connectivity(),
      builder: (controller) {
        return FutureBuilder<int>(
          future: bluetoothConnect(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == 0) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text("List Chat"),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Koneksi Gagal!! Coba lagi...",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        MaterialButton(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          color: Colors.green,
                          onPressed: () {
                            controller.refreshConnection();
                          },
                          child: Text(
                            "Koneksi Ulang",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return GetBuilder<Connectivity>(
                  id: 'updateViewList',
                  init: Connectivity(),
                  builder: (val) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text("List Chat"),
                        actions: [
                          GestureDetector(
                            onTap: () {
                              Get.to(ListNumber(kondisi: 0));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 28,
                                ),
                                Text(
                                  "Nomor Device",
                                  style: TextStyle(
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                      body: Container(
                        width: Get.width,
                        height: Get.height,
                        margin: EdgeInsets.only(bottom: 15),
                        child: FutureBuilder<List<ReadChat>>(
                          future: val.getPesanMain(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var hasil = snapshot.data;
                              return ListView.builder(
                                  itemCount: hasil.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onLongPress: () {
                                        if (kondisiSelected) {
                                          selectedList.removeWhere(
                                            (element) =>
                                                element ==
                                                int.parse(hasil[index].number),
                                          );
                                          if (selectedList.length == 0) {
                                            kondisiSelected = false;
                                            val.refreshViewList();
                                          } else {
                                            val.refreshViewList();
                                          }
                                        } else {
                                          selectedList.add(
                                              int.parse(hasil[index].number));
                                          kondisiSelected = true;
                                          val.refreshViewList();
                                        }
                                      },
                                      onTap: () {
                                        // Get.to(
                                        //   ChatPage(
                                        //     name: hasil[index].nama.toString(),
                                        //     nilai: hasil[index].number.toString(),
                                        //   ),
                                        // );
                                        Get.to(
                                          ChatFix(
                                            nilai:
                                                int.parse(hasil[index].number),
                                            name: hasil[index].nama.toString(),
                                            connection: connection,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: Get.width,
                                        padding: EdgeInsets.only(
                                            right: 12,
                                            left: 12,
                                            top: 15,
                                            bottom: 15),
                                        color: (selectedList.contains(
                                                int.parse(hasil[index].number)))
                                            ? Colors.red.shade500
                                            : Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${hasil[index].nama}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  "${hasil[index].tanggal}",
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "${hasil[index].chat}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                      floatingActionButton: FloatingActionButton(
                        backgroundColor: (kondisiSelected)
                            ? Colors.red.shade900
                            : Colors.blue,
                        onPressed: () async {
                          if (kondisiSelected) {
                            var hasil = await val.deletePesanAll(selectedList);
                            if (hasil == 1) {
                              kondisiSelected = false;
                              val.refreshViewList();
                              selectedList.clear();
                            }
                          } else {
                            // Get.to(ChatPage(nilai: "0"));
                            Get.to(ChatFix(nilai: 0, connection: connection));
                          }
                        },
                        child: (kondisiSelected)
                            ? Icon(Icons.delete)
                            : Icon(Icons.add),
                      ),
                    );
                  },
                );
              }
            } else {
              return Container(
                width: Get.width,
                height: Get.height,
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (!dataString.trim().isEmpty) {
      var getNomor = dataString.split("~")[0];
      var getPesan = dataString.split("~")[1];
      Get.put(Connectivity()).checkNumber(int.parse(getNomor)).then((value) {
        if (value == 0) {
          Get.put(Connectivity()).addNumber("Undefined", getNomor);
          Get.put(Connectivity()).addPesan(getNomor, getPesan, 1);
        } else {
          Get.put(Connectivity()).addPesan(getNomor, getPesan, 1);
        }
      });
      Get.put(Connectivity()).refreshMainChat();
      Get.put(Connectivity()).refreshViewList();
    }
    // if (~index != 0) {
    // setState(() {
    //   messages.add(
    //     _Message(
    //       1,
    //       backspacesCounter > 0
    //           ? _messageBuffer.substring(
    //               0, _messageBuffer.length - backspacesCounter)
    //           : _messageBuffer + dataString.substring(0, index),
    //     ),
    //   );
    //   _messageBuffer = dataString.substring(index);
    // });
    // } else {
    // _messageBuffer = (backspacesCounter > 0
    //     ? _messageBuffer.substring(
    //         0, _messageBuffer.length - backspacesCounter)
    //     : _messageBuffer + dataString);
    // }
  }
}
