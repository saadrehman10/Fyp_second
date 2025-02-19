import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothConnection? connection;
  bool isConnected = false;
  String incomingData = "No data received yet.";
  String dataType = "Unknown";

  // Replace with your Bluetooth device's address
  final String deviceAddress = "00:00:00:00:00:00";

  @override
  void initState() {
    super.initState();
    _connectToBluetooth();
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  void _connectToBluetooth() async {
    try {
      BluetoothConnection newConnection = await BluetoothConnection.toAddress(
        deviceAddress,
      );
      setState(() {
        connection = newConnection;
        isConnected = true;
      });
      print('Connected to the device');

      connection!.input?.listen(_onDataReceived).onDone(() {
        print('Disconnected by remote request');
        setState(() {
          isConnected = false;
        });
      });
    } catch (error) {
      print('Cannot connect, exception occurred: $error');
      setState(() {
        isConnected = false;
      });
    }
  }

  void _onDataReceived(Uint8List data) {
    // Convert data from Uint8List to String.
    String dataString = String.fromCharCodes(data).trim();
    print("Data incoming: $dataString");

    // Parse the data type based on the content
    String type = _parseDataType(dataString);

    setState(() {
      incomingData = dataString;
      dataType = type;
    });
  }

  String _parseDataType(String data) {
    // Assuming the data is sent with a prefix indicating its type.
    // Modify these conditions to match your data format.
    if (data.startsWith("TEMP:")) {
      return "Temperature";
    } else if (data.startsWith("HUM:")) {
      return "Humidity";
    } else if (data.startsWith("PRES:")) {
      return "Pressure";
    }
    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Data Receiver')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bluetooth Connection Status:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  fontSize: 20,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 20),
              Text('Data Type:', style: TextStyle(fontSize: 20)),
              Text(dataType, style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              Text('Data Received:', style: TextStyle(fontSize: 20)),
              Text(incomingData, style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
