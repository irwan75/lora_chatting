import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lora_chatting/views/connection.dart';
import 'package:lora_chatting/views/chat.dart';
import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/controller/database_creator.dart';
import 'package:lora_chatting/views/home.dart';
import 'package:lora_chatting/views/list_chat.dart';
import 'package:lora_chatting/models/storage.dart';
import 'package:lora_chatting/views/list_connection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  List<BluetoothDevice> device = [];

  Future getDevices() async {
    await FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      for (int i = 0; i < bondedDevices.length; i++) {
        device.add(bondedDevices[i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getDevices();
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
            return Home();
          } else {
            if (snapshot.data) {
              return ListConnection(device: device);
            } else {
              return Home();
            }
          }
        },
      ),
    );
  }
}

// class Home extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Connection'),
//         ),
//         body: SelectBondedDevicePage(
//           onCahtPage: (device1) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) {
//                   BluetoothDevice _bluetoothDevice = device1;
//                   Storage.setLoginPref(_bluetoothDevice.address);
//                   // _connect.setBluetoothDevice(device1);
//                   return ListChat();
//                   // return ChatPage(
//                   //   server: device,
//                   // );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
