import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tea_app/models/inventory_item.dart';
import 'package:tea_app/models/task_model.dart';
import 'package:tea_app/pages/App_Pages/addItemsPage.dart';
import 'package:tea_app/pages/App_Pages/itemDetailPage.dart';
import 'package:tea_app/pages/App_Pages/profilePage.dart';

class Itemspage extends StatefulWidget {
  const Itemspage({super.key});

  @override
  State<Itemspage> createState() => _ItemspageState();
}

class _ItemspageState extends State<Itemspage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? userEmail;
  bool isLoading = true;
  List<InventoryItem> items = [];
  List<InventoryItem> filteredItems = [];
  String searchQuery = '';

  final String baseUrl = 'http://192.168.137.1:8000/api';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchInventoryItems();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchUserInfo() async {
    final url = Uri.parse('$baseUrl/auth/me');
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => userEmail = data['email']);
      } else {
        setState(() => userEmail = 'Failed to fetch user info');
      }
    } catch (e) {
      setState(() => userEmail = 'Error: $e');
    }
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
          filteredItems = items;
          isLoading = false;
        });
      } else {
        debugPrint('Failed to fetch inventory items: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
      setState(() => isLoading = false);
    }
  }

  String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];

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
      if (res.statusCode == 200) return true;

      debugPrint('Adjust sale failed: ${res.statusCode} - ${res.body}');
      return false;
    } catch (e) {
      debugPrint('Error adjusting today sale: $e');
      return false;
    }
  }

  void changeQuantity(int index, int delta) async {
    final item = filteredItems[index];
    final newQty = item.quantity + delta;
    if (newQty < 0) return;

    final originalQty = item.quantity;
    setState(() => filteredItems[index].quantity = newQty);

    final ok = await adjustTodaySale(item.id, -delta);
    if (!ok) {
      setState(() => filteredItems[index].quantity = originalQty);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update stock')));
    } else {
      await fetchInventoryItems();
    }
  }

  void _filterItems(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      searchQuery = query;
      filteredItems = items.where((item) {
        return item.name.toLowerCase().contains(lowerQuery) ||
            item.description.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Additemspage()),
          );
        },
        backgroundColor: const Color(0xFF17CF73),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[100],
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home_rounded,
                    color: Colors.black, size: 26),
                onPressed: () {
                  // navigate to home
                },
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.black, size: 26),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                profileImageUrl: 'https://example.com/logo.png',
                                name: 'John Doe',
                                role: 'Admin',
                                email: 'john@example.com',
                                phone: '+91 9876543210',
                                address: '123 Tea Street, Kochi',
                                lastLogin: '2025-09-13 09:30 AM',
                                recentActions: const [
                                  'Added new item: Green Tea',
                                  'Updated stock for Masala Tea',
                                  'Processed Order #1234',
                                ],
                                itemsAdded: 25,
                                ordersProcessed: 102,
                                salesContributed: 45200.75,
                                toDoList: [
                                  Task(
                                      title: 'Prepare order for School A',
                                      dueDate: DateTime(2025, 9, 15)),
                                  Task(
                                      title: 'Restock Milk Powder',
                                      dueDate: DateTime(2025, 9, 17)),
                                ],
                              )));
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      'Inventory',
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
                    child: TextField(
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: 'Search items...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildItemCard(item, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildItemCard(InventoryItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsPage(
                item: item,
                imagePath: 'assets/prod3.png', // same here as well
              ),
            ),
          );
          await fetchInventoryItems();
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/prod3.png', // while working on the backend, give an option to upload pic of the product
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                    if (item.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Epilogue',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey[100],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => changeQuantity(index, -1),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => changeQuantity(index, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
