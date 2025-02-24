import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _deviceAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  // Load saved address from SharedPreferences
  Future<void> _loadSavedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString('device_address');
    if (savedAddress != null) {
      setState(() {
        _deviceAddressController.text = savedAddress;
      });
    }
  }

  // Save address to SharedPreferences
  Future<void> _saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_address', _deviceAddressController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device address saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Settings"),
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

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Enter Bluetooth Device Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _deviceAddressController,
              decoration: const InputDecoration(
                labelText: 'Device Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAddress,
              child: const Text("Save Address"),
            ),
          ],
        ),
      ),
    );
  }
}
