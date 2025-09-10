// lib/pages/App_Pages/itemsPage.dart
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

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchInventoryItems() async {
    final url = Uri.parse('$baseUrl/inventory/');
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

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
        debugPrint("Failed to fetch inventory items: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching items: $e");
    }
  }

  String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];

  // Records a sale for TODAY by calling sales.adjust with date=today
  Future<bool> adjustTodaySale(String id, int change) async {
    final today = _dateKey(DateTime.now());
    final url = Uri.parse('$baseUrl/inventory/$id/sales/adjust');
    final headers = await _getAuthHeaders();

    try {
      final res = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'date': today, 'change': change}),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        debugPrint(
            'Failed to adjust today sale: ${res.statusCode} - ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adjusting today sale: $e');
      return false;
    }
  }

  void changeQuantity(int index, int delta) async {
    final item = items[index];
    final newQty = item.quantity + delta;
    if (newQty < 0) return;

    // Optimistic update in UI
    setState(() => items[index].quantity = newQty);

    final ok = await adjustTodaySale(item.id, delta);
    if (!ok) {
      // revert on failure and show message
      setState(() => items[index].quantity = item.quantity);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update stock')));
    } else {
      // refresh from server to ensure consistency
      await fetchInventoryItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                  const SizedBox(
                    height: 10,
                  ),
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
                            leading: Image.asset('assets/item1.png',
                                width: 40, height: 40, fit: BoxFit.cover),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Epilogue'),
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
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () => changeQuantity(index, -1)),
                                Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 14, fontFamily: 'Epilogue')),
                                IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => changeQuantity(index, 1)),
                              ],
                            ),
                            onTap: () async {
                              // go to details and refresh after returning
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemDetailsPage(
                                        item: item,
                                        imagePath: 'assets/item1.png')),
                              );
                              await fetchInventoryItems();
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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 24, color: Colors.black),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 24, color: Colors.black),
              label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24, color: Colors.black),
              label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Additemspage()));
          }
        },
      ),
    );
  }
}
