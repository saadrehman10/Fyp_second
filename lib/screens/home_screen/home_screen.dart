import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _deviceAddressController =
      TextEditingController();
  BluetoothConnection? connection;
  bool isConnected = false;
  String incomingData = "No data received yet.";
  String dataType = "Unknown";
  List<String> dataList = []; // List to store incoming data history.

  @override
  void dispose() {
    _deviceAddressController.dispose();
    connection?.dispose();
    super.dispose();
  }

  // Connect to a Bluetooth device.
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
        SnackBar(content: Text('Error connecting to device: $error')),
      );
    }
  }

  // Handle incoming data from the Bluetooth device.
  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data).trim();
    print("Data incoming: $dataString");

    String type = _parseDataType(dataString);

    setState(() {
      incomingData = dataString;
      dataType = type;
      dataList.add(dataString);

      // Keep only the last 10 items.
      if (dataList.length > 10) {
        dataList.removeAt(0);
      }
    });

    // Optionally, update the displayed data list every second.
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        incomingData = dataList.join('\n');
      });
    });
  }

  // Parse the data type from the received string.
  String _parseDataType(String data) {
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Bluetooth Data Receiver',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/SettingsScreen');
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
                const Text(
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
                const Text('Data Type:', style: TextStyle(fontSize: 20)),
                Text(dataType, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                const Text('Data Received:', style: TextStyle(fontSize: 20)),
                Text(incomingData, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                const Text(
                  'Data History (Last 10):',
                  style: TextStyle(fontSize: 20),
                ),
                Column(children: dataList.map((data) => Text(data)).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
