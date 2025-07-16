import 'package:flutter/material.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            onPressed: () {},
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
                borderRadius:
                    BorderRadius.circular(12), // Change the value as needed
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Epilogue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
