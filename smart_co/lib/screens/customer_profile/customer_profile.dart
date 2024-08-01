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

  void navigateToUpdateCustomer(BuildContext context, String userEmail) {
    Navigator.pushNamed(context, '/customerupdate', arguments: userEmail);
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Color(0xFF752888)),
                        title: Text('User Name', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['name']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.email, color: Color(0xFF752888)),
                        title: Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['email']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.phone, color: Color(0xFF752888)),
                        title: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['mobile']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.message, color: Color(0xFF752888)),
                        title: Text('Whatsapp Number', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['whatsapp_no']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.call, color: Color(0xFF752888)),
                        title: Text('Telephone Number', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['telephone_no']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.home, color: Color(0xFF752888)),
                        title: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['address']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.flag, color: Color(0xFF752888)),
                        title: Text('Nationality', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['nationality']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.badge, color: Color(0xFF752888)),
                        title: Text('Civil ID', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['civil_id']?.toString() ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.pin_drop, color: Color(0xFF752888)),
                        title: Text('Paci Number', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer['paci_number']?.toString() ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF752888),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      onPressed: userEmail != null
                          ? () => navigateToUpdatePassword(context, userEmail!)
                          : null,
                      child: Text('Update Password', style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF752888),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      onPressed: () => navigateToUpdateCustomer(context, userEmail!),
                      child: Text('Update Profile', style: TextStyle(fontSize: 16)),
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
