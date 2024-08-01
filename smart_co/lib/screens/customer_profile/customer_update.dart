import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomerUpdatePage extends StatefulWidget {
  @override
  _CustomerUpdatePageState createState() => _CustomerUpdatePageState();
}

class _CustomerUpdatePageState extends State<CustomerUpdatePage> {
  final storage = FlutterSecureStorage();

  Map<String, dynamic> customer = {};
  String? userEmail;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController civilIdController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController whatsappNoController = TextEditingController();
  TextEditingController telephoneNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController paciNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        nameController.text = customerData['name'] ?? '';
        emailController.text = customerData['email'] ?? '';
        passwordController.text = customerData['password'] ?? '';
        civilIdController.text = customerData['civil_id']?.toString() ?? '';
        nationalityController.text = customerData['nationality'] ?? '';
        mobileController.text = customerData['mobile']?.toString() ?? '';
        whatsappNoController.text = customerData['whatsapp_no']?.toString() ?? '';
        telephoneNoController.text = customerData['telephone_no']?.toString() ?? '';
        addressController.text = customerData['address'] ?? '';
        paciNumberController.text = customerData['paci_number']?.toString() ?? '';
        });
      }
    } catch (error) {
      print('Error fetching customer: $error');
    }
  }

  void handleLogout() async {
    await storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/');
  }

  void navigateBackToCustomerProfile() {
    Navigator.pushReplacementNamed(context, '/customerProfile');
  }

  Future<void> handleSubmit() async {
    final updatedCustomer = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'civil_id': civilIdController.text,
      'nationality': nationalityController.text,
      'mobile': mobileController.text,
      'whatsapp_no': whatsappNoController.text,
      'telephone_no': telephoneNoController.text,
      'address': addressController.text,
      'paci_number': paciNumberController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('http://podsaas.online/api/customer/${emailController.text}'),
        body: json.encode(updatedCustomer),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Customer updated successfully');
        Navigator.pushReplacementNamed(context, '/customerProfile', arguments: userEmail);
      } else {
        print('Error updating customer: ${response.body}');
      }
    } catch (error) {
      print('Error updating customer: $error');
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
              ),
              TextField(
                controller: mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
              ),
              TextField(
                controller: whatsappNoController,
                decoration: InputDecoration(labelText: 'WhatsApp Number'),
              ),
              TextField(
                controller: telephoneNoController,
                decoration: InputDecoration(labelText: 'Telephone Number'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: nationalityController,
                decoration: InputDecoration(labelText: 'Nationality'),
              ),
              TextField(
                controller: civilIdController,
                decoration: InputDecoration(labelText: 'Civil ID'),
              ),
              TextField(
                controller: paciNumberController,
                decoration: InputDecoration(labelText: 'Paci Number'),
              ),
              ElevatedButton(
                onPressed: handleSubmit,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF752888),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
