import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller to capture user input for the device address.
  final TextEditingController _deviceAddressController =
      TextEditingController();

  BluetoothConnection? connection;
  bool isConnected = false;
  String incomingData = "No data received yet.";
  String dataType = "Unknown";

  // Removed the auto connection from initState.
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _deviceAddressController.dispose();
    connection?.dispose();
    super.dispose();
  }

  void _connectToBluetooth() async {
    final String deviceAddress = _deviceAddressController.text.trim();
    if (deviceAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a device address.')),
      );
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to device.')),
      );
    }
  }

  void _onDataReceived(Uint8List data) {
    // Convert data from Uint8List to String.
    String dataString = String.fromCharCodes(data).trim();
    print("Data incoming: $dataString");

    // Parse the data type based on the content.
    String type = _parseDataType(dataString);

    setState(() {
      incomingData = dataString;
      dataType = type;
    });
  }

  String _parseDataType(String data) {
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Bluetooth Data Receiver'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Bluetooth Data Receiver')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),
                // Input field for the Bluetooth device address.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _deviceAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Device Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _connectToBluetooth,
                  child: const Text('Connect'),
                ),
                const SizedBox(height: 20),
                Text('Data Type:', style: TextStyle(fontSize: 20)),
                Text(dataType, style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Text('Data Received:', style: TextStyle(fontSize: 20)),
                Text(incomingData, style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
