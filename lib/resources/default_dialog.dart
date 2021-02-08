import 'package:flutter/material.dart';
import 'package:get/get.dart';

void defaultDialogCuctom(String text) {
  Get.defaultDialog(
    title: "",
    titleStyle: TextStyle(fontSize: 0),
    content: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
