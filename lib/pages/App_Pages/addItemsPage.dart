import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Additemspage extends StatefulWidget {
  const Additemspage({super.key});

  @override
  State<Additemspage> createState() => _AdditemspageState();
}

class _AdditemspageState extends State<Additemspage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final String apiUrl = "http://192.168.137.1:8000/api/inventory/";

  Future<void> addItem() async {
    final Map<String, dynamic> itemData = {
      "name": itemNameController.text.trim(),
      "quantity": int.tryParse(quantityController.text.trim()) ?? 0,
      "price": double.tryParse(priceController.text.trim()) ?? 0.0,
      "description": descriptionController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(itemData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item added successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add item: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FB), // soft background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Add New Item",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 25),

              // form fields
              buildLabel("Item Name"),
              buildTextField(itemNameController, "Enter item name"),
              const SizedBox(height: 20),

              buildLabel("Quantity"),
              buildTextField(quantityController, "Enter quantity",
                  isNumber: true),
              const SizedBox(height: 20),

              buildLabel("Price"),
              buildTextField(priceController, "Enter price", isNumber: true),
              const SizedBox(height: 20),

              buildLabel("Description"),
              buildTextField(descriptionController, "Enter description",
                  maxLines: 5),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17CF73),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Save Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Epilogue',
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 217, 243, 221), // pale green
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, fontFamily: 'Epilogue'),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
