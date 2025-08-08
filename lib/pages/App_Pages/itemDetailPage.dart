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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Epilogue',
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Epilogue',
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 30),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Epilogue',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
                child: Image.asset(
                  widget.imagePath,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _buildSectionTitle(item.name),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                item.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Epilogue',
                  height: 1.4,
                ),
              ),
            ),
            _buildSectionTitle("Details"),
            _buildDetailRow("Quantity:", "${item.quantity} boxes"),
            _buildDetailRow("Price:", "₹${item.price.toStringAsFixed(2)}"),
            _buildDetailRow("Supplier:", "OLAND TEA"),
            _buildDetailRow("Origin:", "India"),
            _buildSectionTitle("Sales Management"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Current Sales Count",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 28, color: Colors.grey),
                        onPressed: () {
                          // Handle decrement
                        },
                      ),
                      const Text(
                        '120',
                        style: TextStyle(fontSize: 16, fontFamily: 'Epilogue'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            size: 28, color: Colors.grey),
                        onPressed: () {
                          // Handle increment
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSectionTitle("Daily Sales"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
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
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow("Current Sales Count", "15"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Edit
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
                  ElevatedButton(
                    onPressed: () {
                      // Delete
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffBDE5BD),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
