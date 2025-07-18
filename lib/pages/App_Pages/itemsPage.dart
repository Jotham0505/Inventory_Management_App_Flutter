import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Itemspage extends StatefulWidget {
  const Itemspage({super.key});

  @override
  State<Itemspage> createState() => _ItemspageState();
}

class _ItemspageState extends State<Itemspage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      setState(() {
        userEmail = "No token found";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://172.18.106.55:8000/api/auth/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userEmail = data['email'];
          isLoading = false;
        });
      } else {
        setState(() {
          userEmail = "Failed to fetch user info";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userEmail = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 120.0, vertical: 40.0),
          child: Text(
            "Inventory",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Epilogue',
            ),
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 217, 243, 227),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),

        SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            "All Items",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Epilogue',
            ),
          ),
        ),

        Spacer(),

        // Navigation bottom bar
        BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/home.png', width: 24, height: 24),
              label: 'Home',
              activeIcon: Image.asset(
                'assets/home.png',
                width: 24,
                height: 24,
                color: Colors.green, // Change to your desired color
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/search.png', width: 24, height: 24),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/profile.png', width: 24, height: 24),
              label: 'Profile',
            ),
          ],
        ),
      ],
    ));
  }
}
