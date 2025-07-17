import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tea_app/pages/App_Pages/homePage.dart';
import 'package:tea_app/pages/Auth/signupPage.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 320,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Login.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '  Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Epilogue',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _emailController, // ✅ Added controller
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _passwordController, // ✅ Added controller
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                final url =
                    Uri.parse('http://172.18.106.55:8000/api/auth/login');

                try {
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    }),
                  );

                  debugPrint("STATUS CODE: ${response.statusCode}");
                  debugPrint("BODY: ${response.body}");

                  if (response.statusCode == 200) {
                    final token = jsonDecode(response.body)['access_token'];
                    final storage = FlutterSecureStorage();
                    await storage.write(key: 'access_token', value: token);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Homepage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed: ${response.body}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0XFF17CF73),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 140, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupPage()));
              },
              child: Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                  color: Color(0XFF17CF73),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
