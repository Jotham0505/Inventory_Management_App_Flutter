import 'package:flutter/material.dart';

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
          ],
        ),
      ),
    );
  }
}
