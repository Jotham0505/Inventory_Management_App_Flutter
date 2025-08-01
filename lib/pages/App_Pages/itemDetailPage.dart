import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ItemDetailsPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const ItemDetailsPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  Widget build(BuildContext context) {
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
                widget.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Text(
                "A classic herbal tea made from the chamomile flower.", // over here get the description from the item in the database
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
            Divider(
              height: 5,
              indent: 15,
              endIndent: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Quantity", // Example quantity, replace with actual data
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "50 boxes", // Example data, replace with actual data
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 5,
              indent: 15,
              endIndent: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Price", // Example quantity, replace with actual data
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "50 ruppees", // Example data, replace with actual data
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 5,
              indent: 15,
              endIndent: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Supplier", // Example quantity, replace with actual data
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "OLAND TEA", // Example data, replace with actual data
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Additional Information",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            Divider(
              height: 5,
              indent: 15,
              endIndent: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Origin",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "India",
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 5,
              indent: 15,
              endIndent: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Notes",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Smooth, balanced, with a thint of citrus",
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Sales Management",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            Divider(
              height: 5,
              indent: 15,
              endIndent: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Current Sales Count",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 45,
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {},
                    ),
                    Text(
                      '120',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Daily Sales",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
            // add calenddar over here
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
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
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Current Sales Count",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "15",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Epilogue',
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Epilogue',
                        fontSize: 15,
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 196, 196, 196),
                        elevation: 10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Epilogue',
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Color(0xffBDE5BD), elevation: 10),
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
