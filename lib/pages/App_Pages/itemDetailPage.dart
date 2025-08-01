import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tea_app/models/inventory_item.dart';

class ItemDetailsPage extends StatefulWidget {
  final InventoryItem item;
  final String imagePath;

  const ItemDetailsPage({
    Key? key,
    required this.item,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                item.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Details",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            const Divider(indent: 15, endIndent: 15),

            // Quantity
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Quantity",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${item.quantity} boxes',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),

            const Divider(indent: 15, endIndent: 15),

            // Price
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Price",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),

            const Divider(indent: 15, endIndent: 15),

            // Supplier (Static)
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Supplier",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "OLAND TEA",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),

            // Additional Information
            const Divider(indent: 15, endIndent: 15),

            // Origin (Static)
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Origin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "India",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Sales Management
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Sales Management",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            const Divider(indent: 15, endIndent: 15),

            // Sales Counter
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Current Sales Count",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        // You can manage local sales state here
                      },
                    ),
                    const Text(
                      '120',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        // You can manage local sales state here
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Calendar
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Daily Sales",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xffBDE5BD),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.lightBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Dummy Sales Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Current Sales Count",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "15",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Epilogue',
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Edit & Delete Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement Edit
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC4C4C4),
                      elevation: 10,
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Epilogue',
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement Delete
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xffBDE5BD),
                      elevation: 10,
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Epilogue',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
