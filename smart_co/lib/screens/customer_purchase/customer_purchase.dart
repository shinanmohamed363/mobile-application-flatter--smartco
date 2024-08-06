import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class CustomerPurchasePage extends StatefulWidget {
  @override
  _CustomerPurchasePageState createState() => _CustomerPurchasePageState();
}

class _CustomerPurchasePageState extends State<CustomerPurchasePage> {
  Map selling = {};
  List paymentHistory = [];
  List paymentPlan = [];
  String? id;
  String? civilId;
  String? emiNumber;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map?;
      if (arguments != null) {
        id = arguments['id'] as String?;
        userEmail = arguments['email'] as String?;
        if (id != null) {
          fetchSellingDetails(id!);
        } else {
          print('Error: id is null');
        }
      } else {
        print('Error: arguments are null');
      }
    });
    requestPermission();
  }

  Future<void> requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else {
      // Permission denied
    }
  }

  Future fetchSellingDetails(String id) async {
    try {
      final sellingResponse = await http.get(Uri.parse('http://podsaas.online/selling/getOneSellingID/$id'));
      if (sellingResponse.statusCode == 200) {
        setState(() {
          selling = json.decode(sellingResponse.body);
          paymentPlan = selling['customArray'] ?? [];
          civilId = selling['civilID'];
          emiNumber = selling['emiNumber'];
        });

        final newPayments = {
          'civilID': civilId,
          'emiNumber': emiNumber
        };

        final paymentResponse = await http.post(
          Uri.parse('http://podsaas.online/payment/getOnePayment'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newPayments),
        );

        if (paymentResponse.statusCode == 200) {
          setState(() {
            paymentHistory = json.decode(paymentResponse.body);
          });
        }
      }
    } catch (error) {
      print('Error fetching selling details: $error');
    }
  }

  void handleLogout() {
    // Handle logout logic
    Navigator.pushReplacementNamed(context, '/'); // Navigate to login or home screen after logout
  }

  void navigateBackToCustomerHome(BuildContext context, String userEmail) {
    Navigator.pushReplacementNamed(context, '/customerHome', arguments: userEmail);
  }

  Future downloadPDF(Map rowData) async {
    try {
      final response = await http.post(
        Uri.parse('http://podsaas.online/convertToCustomerPaymentInvoicePDF'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(rowData),
      );

      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/PaymentInvoice.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfData);
        OpenFile.open(filePath);
      } else {
        print('Error: Unable to fetch PDF');
      }
    } catch (error) {
      print('Error downloading PDF: $error');
    }
  }

  Future downloadOverallPDF() async {
    if (id != null && civilId != null) {
      try {
        final response = await http.post(
          Uri.parse('http://podsaas.online/convertToOverAllPaymentInvoicePDF'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id': id, 'civil_id': civilId}),
        );

        if (response.statusCode == 200) {
          final pdfData = response.bodyBytes;
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/OverallBill.pdf';
          final file = File(filePath);
          await file.writeAsBytes(pdfData);
          OpenFile.open(filePath);
        } else {
          print('Error: Unable to fetch PDF');
        }
      } catch (error) {
        print('Error downloading PDF: $error');
      }
    } else {
      print('Error: id or civilId is null');
    }
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
            onPressed: () => handleLogout(),
          ),
        ],
      ),
      body: id == null
          ? Center(child: Text('Invalid item ID'))
          : selling.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${selling['deviceName']}',
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Image.network(
                                  selling['imageName'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text('Error loading image');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Plan',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child:DataTable(
                                  columns: [
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Price')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  rows: paymentPlan.map((item) {
                                    return DataRow(cells: [
                                      DataCell(Text(item['date'] ?? '')),
                                      DataCell(Text('${item['price']}')),
                                      DataCell(
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: item['status'] == 'paid' ? Colors.green : Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['status'] == 'paid' ? 'PAID' : 'UNPAID',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  color: Colors.purple.shade100,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Device Price: ${selling['price']}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                      ),
                                      Text(
                                        'Advance: ${selling['advance']}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                      ),
                                      Text(
                                        'Remaining Balance: ${selling['balance']}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: downloadOverallPDF,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 8),
                                      Text(
                                        'Generate Overall Bill',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        Text(
                          'Payment History',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Transaction Date')),
                              DataColumn(label: Text('Payment Amount')),
                              DataColumn(label: Text('Device Name')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: paymentHistory.map((row) {
                              return DataRow(cells: [
                                DataCell(Text(row['date'] ?? '')),
                                DataCell(Text(row['price']?.toString() ?? '')),
                                DataCell(Text(row['deviceName']?.toString() ?? '')),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () => downloadPDF(row),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    ),
                                    child: Text('Download Invoice'),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                        ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
