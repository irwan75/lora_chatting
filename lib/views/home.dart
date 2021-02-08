import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LoRa Chatting"),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.blue,
              ),
              Text("Bluetooth Tidak Aktif"),
            ],
          ),
        ),
      ),
    );
  }
}
