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

        SizedBox(height: 10),

        ListBody(
          children: [
            ListTile(
              leading: Image.asset(
                'assets/item1.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text("Item 1"),
              subtitle: Text("Description of Item 1"),
            ),
            ListTile(
              leading: Image.asset(
                'assets/item2.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text("Item 2"),
              subtitle: Text("Description of Item 2"),
            ),
            ListTile(
              leading: Image.asset(
                'assets/item3.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text("Item 3"),
              subtitle: Text("Description of Item 3"),
            ),
            ListTile(
              leading: Image.asset(
                'assets/item4.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text("Item 4"),
              subtitle: Text("Description of Item 4"),
            ),
          ],
        ),

        Spacer(),

        // Navigation bottom bar
        BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                size: 24,
                color: Colors.black,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
                size: 24,
                color: Colors.black,
              ),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 24,
                color: Colors.black,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ],
    ));
  }
}
