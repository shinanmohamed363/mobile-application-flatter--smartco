import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bcrypt/bcrypt.dart';

class CustomerPasswordPage extends StatefulWidget {
  @override
  _CustomerPasswordPageState createState() => _CustomerPasswordPageState();
}

class _CustomerPasswordPageState extends State<CustomerPasswordPage> {
  final storage = FlutterSecureStorage();

  Map<String, dynamic> customer = {};
  String? userEmail;
  String oldPassword = '';
  String newPassword = '';
  bool isVerified = false;

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
      final response = await http
          .get(Uri.parse('http://podsaas.online/api/users/$userEmail'));
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

  Future<void> handleVerify() async {
    if (customer['password'] != null) {
      bool isMatch = BCrypt.checkpw(oldPassword, customer['password']);
      if (isMatch) {
        setState(() {
          isVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Old password verified successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Old password is incorrect')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No password found for user')));
    }
  }

  Future<void> handleSubmit() async {
    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your old password first')));
      return;
    }

    final updatedUser = {
      'name': customer['name'],
      'email': customer['email'],
      'password': newPassword,
    };

    try {
      final response = await http.put(
        Uri.parse('http://podsaas.online/api/users/${customer['email']}'),
        body: json.encode(updatedUser),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New password updated successfully')));
        Navigator.pushReplacementNamed(context, '/customerProfile', arguments: userEmail);
      } else {
        throw Exception('Failed to update password');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating customer: $error')));
    }
  }

  void handleLogout() async {
    // Clear user details from secure storage
    await storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/');
  }

  void navigateBackToCustomerProfile() {
    Navigator.pushReplacementNamed(context, '/customerProfile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add your old password',
              style: TextStyle(
                fontFamily: 'Public Sans, sans-serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF637381),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Old Password', border: OutlineInputBorder()),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  oldPassword = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF752888),
                foregroundColor: Colors.white,
              ),
              child: Text('Verify'),
            ),
            if (isVerified) ...[
              SizedBox(height: 16.0),
              Text(
                'Update Your New Password',
                style: TextStyle(
                  fontFamily: 'Public Sans, sans-serif',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF637381),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: 'New Password', border: OutlineInputBorder()),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    newPassword = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF752888),
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
