import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool otpBoxVisible = false;
  String buttonLabel = 'Send';
  String generatedOtp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDABCE1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFDA8CC1),
                    child: Icon(Icons.lock_outline, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Forget Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF752888),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF752888)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF752888)),
                      ),
                    ),
                  ),
                  if (otpBoxVisible) ...[
                    SizedBox(height: 20),
                    TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF752888)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF752888)),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: buttonLabel == 'Send'
                        ? handleSubmit
                        : handleOtpVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF752888),
                      foregroundColor: Color(0xFFE0CEE5),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(buttonLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleSubmit() async {
    final email = emailController.text;
    print('Email: $email');

    try {
      final res =
          await http.get(Uri.parse('http://podsaas.online/api/users/$email'));
      if (res.statusCode == 200) {
        final userData = json.decode(res.body);
        print(userData);
        setState(() {
          otpBoxVisible = true;
          buttonLabel = 'Verify OTP';
        });

        final otpCode = (1000 +
                (9999 - 1000) *
                    (new DateTime.now().millisecondsSinceEpoch / 1000)
                        .remainder(1))
            .toInt()
            .toString();
        setGeneratedOtp(otpCode);

        final serviceId = 'service_rp48zn9';
        final templateId = 'template_5upimbk';
        final userId = 'FUl_jD_T0H1wwRm8b';

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final responce = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': userId,
            'template_params': {
              'from_email': 'SmartCo@gmail.com',
              'to_email': userData['email'],
              'customer_name': userData['name'],
              'otp_code': otpCode,
            },
          }));
        print(responce.body);

        print('Email sent');
      } else {
        print('Email not found');
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('Email not found'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'))
                    ]));
      }
    } catch (err) {
      print('Error: $err');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Email is not registered'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'))
                  ]));
    }
  }

  void handleOtpVerification() {
    final otp = otpController.text;
    final userEmail = emailController.text;
    if (otp == generatedOtp) {
      Navigator.pushNamed(context, '/reset_password', arguments: userEmail);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Invalid OTP. Please try again.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'))
                  ]));
    }
  }

  void setGeneratedOtp(String otp) {
    setState(() {
      generatedOtp = otp;
    });
  }
}
