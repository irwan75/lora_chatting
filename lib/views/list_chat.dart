import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:lora_chatting/views/chat.dart';
import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/views/list_number.dart';
import 'package:lora_chatting/views/model_chat.dart';
import 'package:lora_chatting/models/read_chat.dart';

class ListChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Connectivity>(
      init: Connectivity(),
      builder: (val) {
        return Scaffold(
          appBar: AppBar(
            title: Text("List Chat"),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.to(ListNumber());
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
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            // val.setNilai(hasil[index].number);
                            // val.setNilai(hasil[index].number);
                            // Get.to(ModelChat(
                            //     number: int.parse(hasil[index].number)));
                            // print("Storage : ${val.device.address}");
                            // Get.toNamed('/chat_page');
                            Get.to(ChatPage(
                                nilai: hasil[index].number.toString()));
                            // Get.to(ChatPage(server: device1), arguments: "1");
                            // return ChatPage(
                            //   server: device,
                            // );
                          },
                          child: Container(
                            width: Get.width,
                            padding:
                                EdgeInsets.only(right: 12, left: 12, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${hasil[index].number}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${hasil[index].tanggal.split(" ")[0]}",
                                      style: TextStyle(fontSize: 12),
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
            onPressed: () {
              // Get.toNamed('/chat_page');
              Get.to(ChatPage(nilai: "0"));
              // Get.to(
              //   ModelChat(number: 0),
              // );
              // Get.to(ChatPage(server: device1), arguments: "0");
              // val.setNilai("0");
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
