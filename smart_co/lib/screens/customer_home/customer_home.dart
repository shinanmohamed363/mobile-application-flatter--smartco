import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  List<Map<String, dynamic>> sellings = [];
  int unsoldDevicesCount = 0;
  String? userEmail;
  String userCivilID = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      userEmail = ModalRoute.of(context)!.settings.arguments as String?;
      if (userEmail != null) {
        fetchSellings();
        fetchDeviceDetails();
      } else {
        print('Error: email is null');
      }
    });
  }

  Future<void> fetchSellings() async {
    try {
      final customerResponse = await http.get(Uri.parse('http://podsaas.online/api/customer/$userEmail'));
      if (customerResponse.statusCode == 200) {
        final customerData = json.decode(customerResponse.body);
        setState(() {
          userCivilID = customerData['civil_id'];
        });

        final sellingResponse = await http.get(Uri.parse('http://podsaas.online/selling/getOneSelling/$userCivilID'));
        if (sellingResponse.statusCode == 200) {
          final sellingData = json.decode(sellingResponse.body);
          setState(() {
            sellings = List<Map<String, dynamic>>.from(sellingData);
          });
        }
      }
    } catch (error) {
      print('Error fetching sellings: $error');
    }
  }

  Future<void> fetchDeviceDetails() async {
    try {
      final response = await http.get(Uri.parse('http://podsaas.online/device/getDevice'));
      if (response.statusCode == 200) {
        final deviceData = json.decode(response.body);
        setState(() {
          unsoldDevicesCount = deviceData.length;
        });
      }
    } catch (error) {
      print('Error fetching device details: $error');
    }
  }

  void handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
    // Handle logout
  }

  void navigateToProfile(BuildContext context, String userEmail) {
    Navigator.pushNamed(context, '/customerProfile', arguments: userEmail);
  }

  void navigateToDevicePage(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/customerDevice');
    // Navigate to Device Page
  }

  void navigateToCustomerPurchase(BuildContext context, String id) {
    Navigator.pushNamed(context, '/customerPurchase', arguments: id);
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
          icon: Icon(Icons.person),
          onPressed: () {
            if (userEmail != null) {
              navigateToProfile(context, userEmail!);
            } else {
              print('Error: email is null');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Number of devices you can buy from us',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$unsoldDevicesCount',
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => navigateToDevicePage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple, // Background color
                        ),
                        child: Text('FIND YOUR DEVICE'),
                      ),
                      SizedBox(height: 16),
                      Image.network(
                        'https://via.placeholder.com/150', // Replace with your image URL
                        height: 150,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Devices',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: sellings.length,
                    itemBuilder: (context, index) {
                      final selling = sellings[index];
                      return GestureDetector(
                        onTap: () {
                          navigateToCustomerPurchase(context, selling['_id']);
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                selling['imageName'],
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selling['deviceName'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text('Purchase Date: ${selling['date']}'),
                                    Text('Device Price: ${selling['price']}'),
                                    Text('Advance: ${selling['advance']}'),
                                    Text('Remaining Balance: ${selling['balance']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
