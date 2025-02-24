import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermission {
  /// Requests the required Bluetooth permissions.
  /// Returns true if all permissions are granted.
  static Future<bool> requestPermissions() async {
    // Request the necessary permissions.
    var scanStatus = await Permission.bluetoothScan.request();
    var connectStatus = await Permission.bluetoothConnect.request();
    var locationStatus = await Permission.locationWhenInUse.request();

    bool granted =
        scanStatus.isGranted &&
        connectStatus.isGranted &&
        locationStatus.isGranted;
    if (granted) {
      print("Bluetooth permissions granted.");
      await _checkBluetoothEnabled();
    } else {
      print("Bluetooth permissions not granted.");
    }
    return granted;
  }

  /// Checks if Bluetooth is enabled and, if not, requests to enable it.
  static Future<void> _checkBluetoothEnabled() async {
    BluetoothState bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
    } else {
      print("Bluetooth is already enabled.");
    }
  }
}
