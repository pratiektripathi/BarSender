import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHelper {
  static Future<bool> ensureBluetoothIsEnabled() async {
    // Check and request location permission
    if (await Permission.location.request().isGranted) {
      // Check if Bluetooth is on
      FlutterBlue flutterBlue = FlutterBlue.instance;
      bool isBluetoothOn = await flutterBlue.isOn;

      if (!isBluetoothOn) {
        // Prompt user to turn on Bluetooth
        // Note: flutter_blue does not have a direct method to turn on Bluetooth, user interaction is needed
        return false;
      }
      return true;
    }
    return false;
  }
  



}
