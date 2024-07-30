import 'package:flutter/material.dart';
import 'screens/customer_home/customer_home.dart';
import 'screens/customer_device/customer_device.dart';
import 'screens/customer_purchase/customer_purchase.dart';
import 'screens/customer_profile/customer_profile.dart';
import 'screens/customer_profile/customer_password.dart';
import 'screens/login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/customerHome': (context) => CustomerHomePage(),
        '/customerDevice': (context) => CustomerDevicePage(),  // Add this route
        '/customerPurchase': (context) => CustomerPurchasePage(),
        '/customerProfile': (context) => CustomerProfilePage(),
        '/customerpassword': (context) => CustomerPasswordPage(),
        // Define other routes here
      },
    );
  }
}
