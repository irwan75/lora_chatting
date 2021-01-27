import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_storage/get_storage.dart';

class Storage {
  static GetStorage box = GetStorage();

  static setLoginPref(String value) {
    box.write("address", value);
  }

  static String getLoginPref() {
    return box.read("address") ?? "0";
  }
}
