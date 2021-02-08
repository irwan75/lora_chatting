import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/controller/model_chat_controller.dart';
import 'package:lora_chatting/models/message.dart';
import 'package:lora_chatting/models/storage.dart';

class ModelChat extends StatelessWidget {
  int number;
  ModelChat({
    Key key,
    this.number,
  }) : super(key: key);

  BluetoothConnection connection;

  List<Message> messages = List<Message>();
  String _messageBuffer = '';

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  initStateFunction() {
    BluetoothConnection.toAddress(Storage.getAddressPref()).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      // setState(() {
      isConnecting = false;
      isDisconnecting = false;
      // });

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
        // if (this.mounted) {
        // setState(() {});
        // }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((number == 0) ? "New Message" : "Chat ${number}"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: GetBuilder<ModelChatController>(
                init: ModelChatController(),
                initState: initStateFunction(),
                builder: (controller) {
                  return Container();
                },
              ),
            ),
            Container(),
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
      // setState(() {
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
      // });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
