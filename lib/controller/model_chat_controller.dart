import 'package:get/get.dart';

class ModelChatController extends GetxController {
  String number;

  void setNumber(String val) {
    number = val;
    update();
  }
}
