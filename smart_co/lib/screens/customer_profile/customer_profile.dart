import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerProfilePage extends StatefulWidget {
  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  Map<String, dynamic> customer = {};
  String? userEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      userEmail = ModalRoute.of(context)!.settings.arguments as String?;
      if (userEmail != null) {
        fetchCustomer(userEmail!);
      } else {
        print('Error: email is null');
      }
    });
  }

  Future<void> fetchCustomer(String userEmail) async {
    try {
      final response = await http.get(Uri.parse('http://podsaas.online/api/customer/$userEmail'));
      if (response.statusCode == 200) {
        final customerData = json.decode(response.body);
        setState(() {
          customer = customerData;
        });
      }
    } catch (error) {
      print('Error fetching customer: $error');
    }
  }

  void navigateToUpdatePassword(BuildContext context, String userEmail) {
    Navigator.pushNamed(context, '/customerpassword', arguments: userEmail);
  }

  void navigateToUpdateCustomer(BuildContext context) {
    Navigator.pushNamed(context, '/customerupdate');
  }

  void handleLogout(BuildContext context) {
    // Handle logout
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SMARTCO',
          style: TextStyle(
            fontFamily: 'Public Sans, sans-serif',
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: <Color>[Color(0xFFC63DE7), Color(0xFF752888)],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Name: ${customer['name'] ?? ''}'),
                      Text('E-mail: ${customer['email'] ?? ''}'),
                      Text('Mobile: ${customer['mobile'] ?? ''}'),
                      Text('Whatsapp Number: ${customer['whatsapp_no'] ?? ''}'),
                      Text('Telephone Number: ${customer['telephone_no'] ?? ''}'),
                      Text('Address: ${customer['address'] ?? ''}'),
                      Text('Nationality: ${customer['nationality'] ?? ''}'),
                      Text('Civil ID: ${customer['civil_id'] ?? ''}'),
                      Text('Paci Number: ${customer['paci_number'] ?? ''}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: userEmail != null
                          ? () => navigateToUpdatePassword(context, userEmail!)
                          : null,
                      child: Text('Update Password'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => navigateToUpdateCustomer(context),
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
