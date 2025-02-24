import 'package:bio_signal/models/bluetooth_permission.dart';
import 'package:bio_signal/models/shared_prefrenced.dart';
import 'package:bio_signal/screens/flash_screen/flash_screen.dart';
import 'package:bio_signal/screens/home_screen/home_screen.dart';
import 'package:bio_signal/screens/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalStorage.initialize();
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.initialize();
  await BluetoothPermission.requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FlashScreen(),
      routes: {
        '/HomeScreen': (context) => const HomeScreen(),
        '/SettingsScreen': (context) => const SettingsScreen(),
      },
    );
  }
}
