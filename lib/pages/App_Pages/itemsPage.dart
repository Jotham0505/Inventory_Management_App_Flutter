import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tea_app/models/inventory_item.dart';
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
  List<InventoryItem> items = [];

  final String baseUrl = 'http://192.168.137.1:8000/api';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchInventoryItems();
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

    final url = Uri.parse('$baseUrl/auth/me');

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
        });
      } else {
        setState(() {
          userEmail = "Failed to fetch user info";
        });
      }
    } catch (e) {
      setState(() {
        userEmail = "Error: $e";
      });
    }
  }

  Future<void> fetchInventoryItems() async {
    final url = Uri.parse('$baseUrl/inventory/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          items = data.map((json) => InventoryItem.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to fetch inventory items: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching items: $e");
    }
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    final url = Uri.parse('$baseUrl/inventory/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': newQuantity}),
      );

      if (response.statusCode == 200) {
        fetchInventoryItems(); // Refresh the list
      } else {
        print('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  void changeQuantity(int index, int delta) {
    final item = items[index];
    final newQty = item.quantity + delta;

    if (newQty >= 0) {
      updateQuantity(item.id, newQty); // Backend update
      setState(() {
        items[index].quantity = newQty; // UI update
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
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
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "All Items",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            leading: Image.asset(
                              'assets/item1.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Epilogue',
                              ),
                            ),
                            subtitle: Text(
                              item.description,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                fontFamily: 'Epilogue',
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () => changeQuantity(index, -1),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Epilogue',
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => changeQuantity(index, 1),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsPage(
                                    title: item.name,
                                    subtitle: item.description,
                                    imagePath: 'assets/item1.png',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 24, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 24, color: Colors.black),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24, color: Colors.black),
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
        },
      ),
    );
  }
}
