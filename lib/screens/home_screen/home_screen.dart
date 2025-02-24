import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothConnection? connection;
  String _buffer = "";
  bool isConnected = false;
  String incomingData = "No data received yet.";
  List<FlSpot> dataPoints = [
    FlSpot(0, 0),
  ]; // Ensuring at least one point exists
  String? deviceAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceAddress = prefs.getString('device_address');
    });
  }

  void _connectToBluetooth() async {
    if (deviceAddress == null || deviceAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No device address found. Please set it in Settings.'),
        ),
      );
      return;
    }

    try {
      BluetoothConnection newConnection = await BluetoothConnection.toAddress(
        deviceAddress!,
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
        const SnackBar(content: Text('Error connecting to device')),
      );
    }
  }

  void _disconnectBluetooth() async {
    if (connection != null) {
      await connection!.finish();
      setState(() {
        isConnected = false;
        connection = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Disconnected from device')));
    }
  }

  void _onDataReceived(Uint8List data) {
    // Convert incoming bytes to a string and add to the buffer
    String newData = String.fromCharCodes(data);
    _buffer += newData;

    // If the buffer does not contain a newline, wait for more data
    if (!_buffer.contains("\n")) return;

    // Split the buffer by newline to get complete messages
    List<String> messages = _buffer.split("\n");
    // Keep the last fragment (which might be incomplete) in the buffer
    _buffer = messages.removeLast();

    // Process each complete message
    for (String message in messages) {
      // Remove "X:" and "Y:" labels and trim the string
      String cleanedMessage =
          message.replaceAll("X:", "").replaceAll("Y:", "").trim();
      List<String> values = cleanedMessage.split(",");
      if (values.length == 2) {
        try {
          // Parse x and y values, trimming any extra spaces
          double x = double.parse(values[0].trim());
          double y = double.parse(values[1].trim());

          // Clamp x to be between 1 and 5.
          if (x < 1) x = 1;
          if (x > 5) x = 5;

          setState(() {
            dataPoints.add(FlSpot(x, y));
            if (dataPoints.length > 20)
              dataPoints.removeAt(0); // Keep last 20 points
          });
        } catch (e) {
          print("Error parsing X, Y values: $e (Data: $message)");
        }
      }
    }

    // Update the incomingData display with the last fragment (if any)
    setState(() {
      incomingData = _buffer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Data Receiver'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: Text(
                  'Welcome to BIO SIGNAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, size: 20, color: Colors.green),
              title: const Text('Home'),
              trailing: IconButton(
                onPressed:
                    () => Navigator.popAndPushNamed(context, "/HomeScreen"),
                icon: Icon(Icons.arrow_forward, size: 15, color: Colors.black),
              ),
              onTap: () => Navigator.popAndPushNamed(context, "/HomeScreen"),
            ),
            ListTile(
              leading: Icon(Icons.settings, size: 20, color: Colors.green),
              title: const Text('Bluetooth Configrations'),
              trailing: IconButton(
                onPressed:
                    () => Navigator.popAndPushNamed(context, "/SettingsScreen"),
                icon: Icon(Icons.arrow_forward, size: 15, color: Colors.black),
              ),
              onTap:
                  () => Navigator.popAndPushNamed(context, "/SettingsScreen"),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Bluetooth Connection Status: ${isConnected ? 'Connected' : 'Disconnected'}',
                style: TextStyle(
                  fontSize: 20,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _connectToBluetooth,
                    child: const Text(
                      'Connect',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _disconnectBluetooth,
                    child: const Text(
                      'Disconnect',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Data Received:', style: TextStyle(fontSize: 20)),
              Text(incomingData, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // Live Line Graph
              const Text('Live Data Graph:', style: TextStyle(fontSize: 20)),
              Container(
                height: 250,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: 5,
                    minY: 0,
                    maxY: 1023,
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 200),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 1),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dataPoints,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Data History in Row
              const Text('Data History:', style: TextStyle(fontSize: 20)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      dataPoints
                          .map(
                            (point) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "(${point.x.toStringAsFixed(1)}, ${point.y.toStringAsFixed(1)})",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
