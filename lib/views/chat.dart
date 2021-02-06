import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/models/read_chat_details.dart';
import 'package:lora_chatting/models/storage.dart';
import 'package:lora_chatting/views/list_number.dart';

import '../models/message.dart';

class ChatPage extends StatefulWidget {
  // final BluetoothDevice server;

  // const ChatPage({this.server});
  String nilai;
  ChatPage({
    Key key,
    this.nilai,
  }) : super(key: key);

  @override
  _ChatPage createState() => new _ChatPage(nilai);
}

class _ChatPage extends State<ChatPage> {
  final Connectivity _connect = Get.find();

  String nilai;

  _ChatPage(this.nilai);

  static final clientID = 0;
  BluetoothConnection connection;

  List<Message> messages = List<Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  TextEditingController _formNumber = TextEditingController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    try {
      BluetoothConnection.toAddress(Storage.getLoginPref()).then((_connection) {
        print('Connected to the device');
        connection = _connection;
        setState(() {
          isConnecting = false;
          isDisconnecting = false;
        });

        connection.input.listen(_onDataReceived).onDone(() {
          // Example: Detect which side closed the connection
          // There should be `isDisconnecting` flag to show are we are (locally)
          // in middle of disconnecting process, should be set before calling
          // `dispose`, `finish` or `close`, which all causes to disconnect.
          // If we except the disconnection, `onDone` should be fired as result.
          // If we didn't except this (no flag set), it means closing by remote.
          if (isDisconnecting) {
            print('Disconnecting locally!');
          } else {
            print('Disconnected remotely!');
          }
          if (this.mounted) {
            setState(() {});
          }
        });
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              (text) {
                return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
              }(_message.text.trim()),
              style: TextStyle(
                  color: (_message.whom == clientID)
                      ? Colors.white
                      : Colors.black),
            ),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
              color: _message.whom == clientID
                  ? Colors.blueAccent
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (nilai == "0") ? Text("New Message") : Text("Chat ${nilai}")),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Container(
            //   padding: const EdgeInsets.all(5),
            //   width: double.infinity,
            //   child: FittedBox(
            //     child: Row(
            //       children: [
            //         FlatButton(
            //           onPressed: isConnected ? () => _sendMessage('1') : null,
            //           child: ClipOval(
            //               child: Image.asset('assets/images/ledOn.png')),
            //         ),
            //         FlatButton(
            //           onPressed: isConnected ? () => _sendMessage('0') : null,
            //           child: ClipOval(
            //               child: Image.asset('assets/images/ledOff.png')),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            (nilai != "0")
                ? Container()
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    width: Get.width,
                    child: TextFormField(
                      // controller: _formNumber = TextEditingController(
                      // text:
                      // (Get.arguments == "0") ? "" : Get.arguments.toString()),
                      keyboardType: TextInputType.number,
                      controller: _formNumber,
                      decoration: InputDecoration(
                        hintText: "Kepada:",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.person),
                          onPressed: () async {
                            var kondisi = await Get.to(ListNumber());
                            print("Adakah : $kondisi");
                          },
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                    ),
                  ),
            Flexible(
              child: FutureBuilder<List<ReadChatDetail>>(
                future: _connect.getPesan(nilai),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var hasil = snapshot.data;
                    if (hasil.isEmpty) {
                      return Container();
                    } else {
                      // return ListView(
                      //     padding: const EdgeInsets.all(12.0),
                      //     controller: listScrollController,
                      //     children: list);
                      return Container(
                        margin: EdgeInsets.only(top: 15),
                        child: ListView.builder(
                          controller: listScrollController,
                          itemCount: hasil.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      (text) {
                                        return text == '/shrug'
                                            ? '¯\\_(ツ)_/¯'
                                            : text;
                                      }(hasil[index].chat.trim()),
                                      style: TextStyle(
                                          color: (hasil[index].rule != "0")
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    padding: EdgeInsets.all(12.0),
                                    margin: EdgeInsets.only(
                                        bottom: 8.0, left: 8.0, right: 8.0),
                                    width: 222.0,
                                    decoration: BoxDecoration(
                                      color: (hasil[index].rule != "0")
                                          ? Colors.blueAccent
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(7.0),
                                    ),
                                  ),
                                ],
                                mainAxisAlignment: hasil[index].rule != "0"
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                              ),
                            );
                          },
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      minLines: 1,
                      maxLines: 10,
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                                ? 'Type your message...'
                                : 'Chat got disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: isConnected
                          ? () {
                              if (textEditingController.text.trim() == "") {
                                print("Mohon Isi Pesan Terlebih Dahulu");
                              } else {
                                if (nilai == "0") {
                                  if (_formNumber.text.trim() == "") {
                                    print("Mohon Isi Nomor Terlebih Dahulu");
                                  } else {
                                    // _connect.setNilai(_formNumber.text.trim());
                                    // TODO: terdapat add number yang masih statis statusnya
                                    // _connect.addNumber(
                                    //     "okee", "${_formNumber.text.trim()}");
                                    _connect.addPesan(_formNumber.text.trim(),
                                        textEditingController.text.trim(), 0);
                                    _sendMessage(
                                        "${textEditingController.text.trim()}",
                                        "${_formNumber.text.trim()}");
                                  }
                                } else {
                                  _connect.addPesan(
                                      nilai, textEditingController.text, 0);
                                  _sendMessage("${textEditingController.text}",
                                      "${nilai.trim()}");
                                }
                              }
                            }
                          : null),
                ),
              ],
            )
          ],
        ),
      ),
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
    if (~index != 0) {
      setState(() {
        messages.add(
          Message(
            whom: 1,
            text: backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text, String number) async {
    text = text.trim();
    textEditingController.clear();

    var pesan = "$number~$text";

    if (pesan.length > 0) {
      try {
        // connection.output.add(utf8.encode(text + "\r\n"));
        connection.output.add(utf8.encode(pesan + "\r"));
        await connection.output.allSent;

        // setState(() {
        //   messages.add(_Message(clientID, text));
        // });

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        //   listScrollController.animateTo(
        //       listScrollController.position.maxScrollExtent,
        //       duration: Duration(milliseconds: 333),
        //       curve: Curves.easeOut);
        // });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
