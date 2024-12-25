import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHelper {
  static Future<bool> ensureBluetoothIsEnabled() async {
    // Request location permissions if not already granted
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }

    // Check if location permission is granted
    if (await Permission.location.isGranted) {
      // Check Bluetooth state

      final bluetoothState = await FlutterBluePlus.state.first;

      if (bluetoothState != BluetoothState.on) {
        // Prompt user to turn on Bluetooth manually
        // FlutterBlue does not provide a way to toggle Bluetooth programmatically
        print('Bluetooth is off. Please turn it on.');
        return false;
      }
      return true; // Bluetooth is on and permissions are granted
    } else {
      print('Location permission not granted.');
      return false;
    }
  }
}
