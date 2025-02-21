import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

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
  List<String> dataList = []; // List to store incoming data every second

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions(); // Request permissions at startup
  }

  @override
  void dispose() {
    _deviceAddressController.dispose();
    connection?.dispose();
    super.dispose();
  }

  // Request Bluetooth permissions using permission_handler
  Future<void> _requestBluetoothPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();

    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.locationWhenInUse.isGranted) {
      print("Bluetooth permissions granted.");
      _checkBluetoothEnabled(); // Ensure Bluetooth is enabled if permissions are granted
    } else {
      print("Bluetooth permissions not granted.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please grant Bluetooth permissions.")),
      );
    }
  }

  // Check if Bluetooth is enabled
  Future<void> _checkBluetoothEnabled() async {
    BluetoothState bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
    } else {
      print("Bluetooth is already enabled.");
    }
  }

  // Connect to Bluetooth device
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
        SnackBar(
          content: Text('Error connecting to device. ${error.toString()}'),
        ),
      );
    }
  }

  // Handle incoming data from the Bluetooth device
  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data).trim();
    print("Data incoming: $dataString");

    String type = _parseDataType(dataString);

    setState(() {
      incomingData = dataString;
      dataType = type;

      // Add the incoming data to the list
      dataList.add(dataString);

      // Limit the data list to show only the last 10 items
      if (dataList.length > 10) {
        dataList.removeAt(0); // Remove the first item if there are more than 10
      }
    });

    // Delay the next data display by 1 second
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        // Display the updated list every second
        incomingData = dataList.join('\n');
      });
    });
  }

  // Parse the data type (e.g., TEMP, HUM, PRES) from the received data
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
                const SizedBox(height: 20),
                Text('Data History (Last 10):', style: TextStyle(fontSize: 20)),
                Column(children: dataList.map((data) => Text(data)).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
