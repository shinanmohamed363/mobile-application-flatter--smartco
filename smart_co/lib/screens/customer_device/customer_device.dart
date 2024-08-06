import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerDevicePage extends StatefulWidget {
  @override
  _CustomerDevicePageState createState() => _CustomerDevicePageState();
}

class _CustomerDevicePageState extends State<CustomerDevicePage> {
  List<dynamic> devices = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      userEmail = ModalRoute.of(context)!.settings.arguments as String?;
      if (userEmail != null) {
        fetchDevices();
      } else {
        print('Error: email is null');
      }
    });
  }

  Future<void> fetchDevices() async {
    try {
      final response = await http.get(Uri.parse('http://podsaas.online/device/getDevice'));
      if (response.statusCode == 200) {
        setState(() {
          devices = json.decode(response.body);
        });
      }
    } catch (error) {
      print('Error fetching devices: $error');
    }
  }

  void handleLogout(BuildContext context) {
    // Handle logout
    Navigator.pushReplacementNamed(context, '/');
  }

  void navigateBackToCustomerHome(BuildContext context, String userEmail) {
    Navigator.pushReplacementNamed(context, '/customerHome', arguments: userEmail);
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
          onPressed: () => navigateBackToCustomerHome(context, userEmail!),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => handleLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Our Devices',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Public Sans, sans-serif',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'If you want to buy any device contact us\nour mobile number: 071697433',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Public Sans, sans-serif',
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16.0), // Add padding to the bottom
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3, // Adjust the aspect ratio to fit the content
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              device['imageName'],
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device['deviceName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Public Sans, sans-serif',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Price: ${device['price']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Public Sans, sans-serif',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
