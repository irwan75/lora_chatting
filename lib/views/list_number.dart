import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lora_chatting/controller/connectivity.dart';
import 'package:lora_chatting/controller/nomor_device_controller.dart';
import 'package:lora_chatting/models/list_nomor.dart';

class ListNumber extends StatelessWidget {
  int kondisi;

  ListNumber({
    Key key,
    this.kondisi,
  }) : super(key: key);

  TextEditingController _formNama = TextEditingController();
  TextEditingController _formNumber = TextEditingController();

  List<int> selectedList = [];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NomorDeviceController>(
      init: NomorDeviceController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text((kondisi == 1) ? "Pilih Nomor Tujuan" : "Nomor Device"),
            automaticallyImplyLeading: (kondisi == 1) ? false : true,
          ),
          body: FutureBuilder<List<ListNomor>>(
            future: Connectivity().getNumberDevice(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var hasil = snapshot.data;
                return ListView.builder(
                  itemCount: hasil.length,
                  itemBuilder: (context, index) {
                    return Material(
                      child: InkWell(
                        onTap: () {
                          if (kondisi == 1) {
                            Map<String, dynamic> _nilai = {
                              'nama': hasil[index].nama,
                              'number': hasil[index].number
                            };
                            Get.back(result: _nilai);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasil[index].nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "${hasil[index].number}",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.defaultDialog(
                title: "",
                titleStyle: TextStyle(fontSize: 0),
                content: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        "Form Tambah Nomor",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        maxLength: 20,
                        controller: _formNama,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          hintText: "Nama Device",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        controller: _formNumber,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          hintText: "Nomor Device",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      MaterialButton(
                        color: Colors.blue,
                        onPressed: () {
                          Get.back();
                          Connectivity()
                              .addNumber(_formNama.text, _formNumber.text);
                          controller.refreshPage();
                          _formNama.clear();
                          _formNumber.clear();
                        },
                        child: Text(
                          "Tambah",
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
            },
            child: Icon(
              Icons.group_add,
            ),
          ),
        );
      },
    );
  }
}
