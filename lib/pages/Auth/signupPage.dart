import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 30),
                SizedBox(
                  width: 90,
                ),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Epilogue',
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () async {
                final url = Uri.parse('http://127.0.0.1:8000/signup');
                final response = await http.post(url, body: {
                  'username': _usernameController.text,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                });
                if (response.statusCode == 200) {
                  final token = jsonDecode(response.body)['access_token'];
                  final storage = FlutterSecureStorage();
                  await storage.write(key: 'access_token', value: token);
                  // Navigate to the home page or another page
                  Navigator.pushReplacementNamed(context, '/home');
                  // Handle successful signup
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Signup successful!')),
                  );
                } else {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Signup failed!')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0XFF17CF73),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Change the value as needed
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
