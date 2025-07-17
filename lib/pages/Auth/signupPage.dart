import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tea_app/pages/App_Pages/homePage.dart';

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
              children: [
                const Icon(Icons.arrow_back, size: 30),
                const SizedBox(width: 90),
                const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Epilogue',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(_usernameController, 'Username'),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email'),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, 'Password', obscure: true),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final storage = FlutterSecureStorage();
                final url = Uri.parse(
                    'http://172.18.106.55:8000/api/auth/signup'); // ✅ Fixed path

                try {
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'username': _usernameController.text,
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    }),
                  );

                  debugPrint("STATUS CODE: ${response.statusCode}");
                  debugPrint("BODY: ${response.body}");

                  if (response.statusCode == 201) {
                    // ✅ Fixed status code
                    final token = jsonDecode(response.body)['access_token'];
                    await storage.write(key: 'access_token', value: token);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Homepage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signup successful!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Signup failed: ${response.body}')),
                    );
                  }
                } catch (e) {
                  debugPrint("EXCEPTION: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0XFF17CF73),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 217, 243, 227),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller, // ✅ connected the controller
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }
}
