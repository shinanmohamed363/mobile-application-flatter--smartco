import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
  fetchDevices();

  // Ensure the widget is fully mounted before accessing context
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    print('Arguments received: $arguments'); // Debugging line

    // Check if the arguments are passed correctly
    if (arguments != null && arguments is String) {
      userEmail = arguments;
      print('User email retrieved: $userEmail');
    } else {
      print('Error: email is null or not passed correctly');
    }
  });
}

  Future<void> fetchDevices() async {
    try {
      final response = await http.get(Uri.parse('https://app.smartco.live/device/getDevice'));

      if (response.statusCode == 200) {
        setState(() {
          devices = json.decode(response.body);
        });
      } else {
        print('Failed to load devices. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching devices: $error');
    }
  }

  void _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

 void navigateBackToCustomerHome(BuildContext context, String userEmail) {
  print('Navigating to customer home with email: $userEmail');
  Navigator.pushReplacementNamed(context, '/customerHome', arguments: userEmail);
}

 void showDeviceDetails(BuildContext context, dynamic device) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device name with more style
              Text(
                device['deviceName'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 16),
              
              // Device image with rounded corners and shadow effect
             ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Image.network(
    device['imageName'],
    fit: BoxFit.contain, // Ensures the image fits without cropping or distorting
    height: 220,
    width: double.infinity,
    errorBuilder: (context, error, stackTrace) {
      return Icon(Icons.image, size: 50, color: Colors.grey);
    },
  ),
),
              SizedBox(height: 16),
              
              // Specifications Title with styling
              Text(
                'Specifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 8),

              // Specifications Table with two columns (Features and Details)
              Table(
                border: TableBorder.all(color: Colors.grey, width: 1), // Table border
                columnWidths: {
                  0: FlexColumnWidth(1), // First column (Features) takes 1 part of the space
                  1: FlexColumnWidth(2), // Second column (Details) takes 2 parts of the space
                },
                children: [
                  _buildTableRow('Price', '${device['price']}'),
                  _buildTableRow('Color', '${device['color']}'),
                  _buildTableRow('Model', '${device['modelNumber']}'),
                  _buildTableRow('Storage', '${device['storage']} GB'),
                  _buildTableRow('RAM', '${device['ram']} GB'),
                  _buildTableRow('Warranty', '${device['warrenty']}'),
                  _buildTableRow('EMI Number', '${device['emiNumber']}'),
                ],
              ),
              SizedBox(height: 16),
              
              // Company Phone Number section
              Text(
                'Company Mobile Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 8),

              // Phone number with underline and clickable effect
              GestureDetector(
                onTap: () {
                  _launchPhoneDialer('+96569966882');
                },
                child: Text(
                  '+96569966882',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Close button with gradient background
             Align(
  alignment: Alignment.center,
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
    ),
    child: ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop(); // Close the dialog
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.purple, // Use backgroundColor instead of primary
        foregroundColor: Colors.white, // White text color
      ),
      child: Text(
        'Close',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Ensure the text color is white
        ),
      ),
    ),
  ),
)

            ],
          ),
        ),
      );
    },
  );
}

// Helper method to build table rows with two columns (Feature, Detail)
TableRow _buildTableRow(String feature, String detail) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          feature,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(detail),
      ),
    ],
  );
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
        onPressed: () {
          if (userEmail != null && userEmail!.isNotEmpty) {
            Navigator.pushReplacementNamed(context, '/yourScreen', arguments: userEmail);
          } else {
            print('Error: User email is null or empty');
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
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'If you want to buy any device contact us\nour mobile number:',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Public Sans, sans-serif',
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              _launchPhoneDialer('+96569966882');
            },
            child: Text(
              '+96569966882',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Public Sans, sans-serif',
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Show one item per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2, // Increase this to make the card shorter
              ),
              itemCount: devices.length, // Length of the devices array
              itemBuilder: (context, index) {
                final device = devices[index]; // Get device details for each item

                return SizedBox(
                  height: 130, // Reduce the height of the card here
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  device['imageName'],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image, size: 50, color: Colors.grey);
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
                              SizedBox(width: 12), // Adjust the width slightly
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device['deviceName'],
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis, // Handle overflow for long text
                                      maxLines: 2, // Allow a maximum of 2 lines
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Price: ${device['price']}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1, // Limit to one line
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Model: ${device['modelNumber']}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Warranty: ${device['warrenty']}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight, // Aligns the button to the bottom right
                            child: ElevatedButton(
                              onPressed: () => showDeviceDetails(context, device),
                              child: Text('View Details'),
                            ),
                          ),
                        ],
                      ),
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
