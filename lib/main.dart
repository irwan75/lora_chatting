import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lora_chatting/connection.dart';
import 'package:lora_chatting/chat.dart';
import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/controller/database_creator.dart';
import 'package:lora_chatting/list_chat.dart';
import 'package:lora_chatting/models/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage(name: '/list_chat', page: () => ListChat()),
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text("LoRa Chatting"),
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
          } else if (snapshot.connectionState == ConnectionState.none) {
            return Home();
          } else {
            return Home();
          }
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  // final Connectivity _connect = Get.put(Connectivity());

  @override
  Widget build(BuildContext context) {
    // Connectivity().addNumber("2837928");
    // Connectivity().addNumber("1236781");
    // for (int i = 0; i < 4; i++) {
    //   Connectivity().addPesan("2837928", "saddsa $i", 1);
    //   Connectivity().addPesan("1236781", "sada $i", 0);
    // }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Connection'),
        ),
        body: SelectBondedDevicePage(
          onCahtPage: (device1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  BluetoothDevice _bluetoothDevice = device1;
                  Storage.setLoginPref(_bluetoothDevice.address);
                  // _connect.setBluetoothDevice(device1);
                  return ListChat();
                  // return ChatPage(
                  //   server: device,
                  // );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
