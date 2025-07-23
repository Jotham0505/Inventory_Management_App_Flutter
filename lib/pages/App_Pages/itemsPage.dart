import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tea_app/pages/App_Pages/addItemsPage.dart';
import 'package:tea_app/pages/App_Pages/itemDetailPage.dart';

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
        SizedBox(
          height: 25,
        ),
        Center(
          child: Text(
            "Inventory",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Epilogue',
            ),
          ),
        ),

        SizedBox(
          height: 20,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            "All Items",
            style: TextStyle(
              fontSize: 24,
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
              title: Text(
                "Matcha",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Epilogue',
                ),
              ),
              subtitle: Text(
                "Green Tea",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Epilogue',
                    color: Colors.grey),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                    ),
                    onPressed: () {
                      // TODO: Implement remove item logic
                    },
                  ),
                  Text(
                    "10",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 18),
                    onPressed: () {
                      // TODO: Implement add item logic
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsPage(
                      title: "Matcha",
                      subtitle: "Green Tea",
                      imagePath: 'assets/item11.png',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/item2.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text(
                "Earl Grey",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Epilogue',
                ),
              ),
              subtitle: Text(
                "Black Tea",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Epilogue',
                    color: Colors.grey),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                    ),
                    onPressed: () {
                      // TODO: Implement remove item logic
                    },
                  ),
                  Text(
                    "10",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 18),
                    onPressed: () {
                      // TODO: Implement add item logic
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsPage(
                      title: "Earl Grey",
                      subtitle: "Black Tea",
                      imagePath: 'assets/item22.png',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/item3.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text(
                "Chamomile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Epilogue',
                ),
              ),
              subtitle: Text(
                "Herbal Tea",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Epilogue',
                    color: Colors.grey),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                    ),
                    onPressed: () {
                      // TODO: Implement remove item logic
                    },
                  ),
                  Text(
                    "10",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 18),
                    onPressed: () {
                      // TODO: Implement add item logic
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsPage(
                      title: "Chamomile",
                      subtitle: "Herbal Tea",
                      imagePath: 'assets/item33.png',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/item4.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text(
                "Tieguan Yin",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Epilogue',
                ),
              ),
              subtitle: Text(
                "Oolong Tea",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Epilogue',
                    color: Colors.grey),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                    ),
                    onPressed: () {
                      // TODO: Implement remove item logic
                    },
                  ),
                  Text(
                    "10",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 18),
                    onPressed: () {
                      // TODO: Implement add item logic
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsPage(
                      title: "Tieguan Yin",
                      subtitle: "Oolong Tea",
                      imagePath: 'assets/item44.png',
                    ),
                  ),
                );
              },
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
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Additemspage()),
              );
            }
            // You can handle other indices if needed
          },
        ),
      ],
    ));
  }
}
