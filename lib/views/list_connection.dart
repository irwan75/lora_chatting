import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:lora_chatting/models/storage.dart';
import 'package:lora_chatting/views/list_chat.dart';

class ListConnection extends StatelessWidget {
  List<BluetoothDevice> device;
  ListConnection({
    Key key,
    this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connection"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: device.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.devices),
              title: Text("${device[index].name}"),
              subtitle: Text("${device[index].address}"),
              trailing: FlatButton(
                child: Text(
                  'Connect',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Storage.setAddressPref(device[index].address);
                  Get.to(ListChat());
                },
                color: Colors.blue,
              ),
            );
          },
        ),
      ),
    );
  }
}
