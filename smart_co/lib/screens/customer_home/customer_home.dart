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

  void navigateToCustomerPurchase(BuildContext context, String id, String userEmail) {
    Navigator.pushNamed(context, '/customerPurchase', arguments: {'id': id, 'email': userEmail});
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.purple[50],
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Number of devices you can buy from us',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                        textAlign: TextAlign.center,
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
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text('FIND YOUR DEVICE', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: 16),
                      Image.asset(
                        'assets/customerImage.png', // Replace with your image URL
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
                          if (userEmail != null) {
                            navigateToCustomerPurchase(context, selling['_id'], userEmail!);
                          } else {
                            print('Error: email is null');
                          }
                        },
                        child: Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0),
  ),
  elevation: 8,
  shadowColor: Colors.purple.withOpacity(0.5),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        child: Image.network(
          selling['imageName'],
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selling['deviceName'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Purchase Date: ${selling['date']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Device Price: ${selling['price']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Advance: ${selling['advance']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Remaining Balance: ${selling['balance']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
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
