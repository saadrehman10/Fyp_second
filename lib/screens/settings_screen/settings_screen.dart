import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setting"), centerTitle: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Bluetooth Data Receiver',
                style: TextStyle(color: Colors.white),
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
              title: const Text('Settings'),
              trailing: IconButton(
                onPressed:
                    () => Navigator.popAndPushNamed(context, "/SettingScreen"),
                icon: Icon(Icons.arrow_forward, size: 15, color: Colors.black),
              ),
              onTap: () => Navigator.popAndPushNamed(context, "/SettingScreen"),
            ),
          ],
        ),
      ),
      body: Column(children: [

        ],
      ),
    );
  }
}
