// lib/pages/App_Pages/itemDetailPage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  int remainingQuantity = 0;
  int salesForSelectedDay = 0;
  bool _isAdjusting = false;

  final String baseUrl = 'http://192.168.137.1:8000/api';

  @override
  void initState() {
    super.initState();
    remainingQuantity = widget.item.quantity;
    _selectedDay = DateTime.now();
    _loadSalesForSelectedDay();
    _refreshRemainingFromServer();
  }

  String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];

  Future<void> _refreshRemainingFromServer() async {
    final url = Uri.parse('$baseUrl/inventory/${widget.item.id}');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final qtyRaw = jsonBody['quantity'];
        final int serverQty = qtyRaw is int
            ? qtyRaw
            : (qtyRaw is num
                ? qtyRaw.toInt()
                : int.tryParse(qtyRaw?.toString() ?? '') ?? remainingQuantity);

        setState(() {
          remainingQuantity = serverQty;
        });
      }
    } catch (e) {
      debugPrint('Error fetching item: $e');
    }
  }

  Future<void> _loadSalesForSelectedDay() async {
    if (_selectedDay == null) return;
    final dateStr = _dateKey(_selectedDay!);
    final url =
        Uri.parse('$baseUrl/inventory/${widget.item.id}/sales/$dateStr');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final dynamic cnt = jsonBody['count'];
        final int serverCount = cnt is int
            ? cnt
            : (cnt is num
                ? cnt.toInt()
                : int.tryParse(cnt?.toString() ?? '') ?? 0);
        setState(() {
          salesForSelectedDay = serverCount;
        });
      } else {
        setState(() => salesForSelectedDay = 0);
      }
    } catch (e) {
      debugPrint('Error loading sales: $e');
      setState(() => salesForSelectedDay = 0);
    }
  }

  Future<void> adjustSalesForDay(int change) async {
    if (_selectedDay == null || _isAdjusting) return;
    final dateStr = _dateKey(_selectedDay!);
    final url = Uri.parse('$baseUrl/inventory/${widget.item.id}/sales/adjust');

    // Save previous values so we can roll back on failure
    final prevRemaining = remainingQuantity;
    final prevSales = salesForSelectedDay;

    // Optimistic update (immediate UI feedback)
    setState(() {
      // change >0 = sell, so remaining decreases
      remainingQuantity = (remainingQuantity - change).clamp(0, 1 << 31);
      salesForSelectedDay = (salesForSelectedDay + change).clamp(0, 1 << 31);
      _isAdjusting = true;
    });

    try {
      final res = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'date': dateStr, 'change': change}),
      );

      if (res.statusCode == 200) {
        // parse server response safely
        final jsonBody = jsonDecode(res.body);

        // parse quantity safely
        final qtyRaw = jsonBody['quantity'];
        final int serverQty = qtyRaw is int
            ? qtyRaw
            : (qtyRaw is num
                ? qtyRaw.toInt()
                : int.tryParse(qtyRaw?.toString() ?? '') ?? prevRemaining);

        // parse sales map safely (handle Map<dynamic,dynamic>)
        final dynamic rawSales = jsonBody['sales'] ?? {};
        final Map<String, dynamic> salesMap = {};
        if (rawSales is Map) {
          // ensure keys are strings
          rawSales.forEach((k, v) {
            salesMap[k.toString()] = v;
          });
        }

        // get value for selected date, fallback to prevSales + change
        final dynamic salesValRaw = salesMap[dateStr];
        final int serverSales = salesValRaw is int
            ? salesValRaw
            : (salesValRaw is num
                ? salesValRaw.toInt()
                : int.tryParse(salesValRaw?.toString() ?? '') ??
                    (prevSales + change));

        setState(() {
          remainingQuantity = serverQty;
          salesForSelectedDay = serverSales;
        });
      } else {
        // server returned non-200 -> revert optimistic update
        setState(() {
          remainingQuantity = prevRemaining;
          salesForSelectedDay = prevSales;
        });
        debugPrint('Failed to adjust sales: ${res.statusCode} - ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update sales: ${res.statusCode}')),
        );
      }
    } catch (e, st) {
      // network or parsing error -> revert optimistic update
      setState(() {
        remainingQuantity = prevRemaining;
        salesForSelectedDay = prevSales;
      });
      debugPrint('Error adjusting sales: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network or parsing error, try again')),
      );
    } finally {
      setState(() => _isAdjusting = false);
    }
  }

  Future<void> setRemainingQuantityManually() async {
    final controller =
        TextEditingController(text: remainingQuantity.toString());
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set remaining quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter remaining boxes'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Set')),
        ],
      ),
    );

    if (result == null) return;
    final newQty = int.tryParse(result);
    if (newQty == null || newQty < 0) return;

    final url = Uri.parse('$baseUrl/inventory/${widget.item.id}/set_quantity');
    try {
      final res = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': newQty}),
      );
      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final qtyRaw = jsonBody['quantity'];
        final int serverQty = qtyRaw is int
            ? qtyRaw
            : (qtyRaw is num
                ? qtyRaw.toInt()
                : int.tryParse(qtyRaw?.toString() ?? '') ?? newQty);
        setState(() => remainingQuantity = serverQty);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Quantity updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to set quantity')));
      }
    } catch (e) {
      debugPrint('Error setting quantity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error setting quantity')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image + Title + Description
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
                child: Image.asset(widget.imagePath,
                    width: double.infinity, height: 250, fit: BoxFit.cover),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(item.name,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold))),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(item.description,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87, height: 1.3))),

            // Details
            const SizedBox(height: 12),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Details',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(
                dense: true,
                title: const Text('Remaining'),
                trailing: Text('$remainingQuantity')),
            ListTile(
                dense: true,
                title: const Text('Price'),
                trailing: Text('₹${item.price.toStringAsFixed(2)}')),
            ListTile(
                dense: true,
                title: const Text('Supplier'),
                trailing: const Text('OLAND TEA')),

            // Sales Management
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Sales Management',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
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
                    _loadSalesForSelectedDay();
                  },
                ),
              ),
            ),

            // Sales counter row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sales on ${_dateKey(_selectedDay ?? DateTime.now())}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _isAdjusting
                              ? null
                              : () => adjustSalesForDay(-1)),
                      Text('$salesForSelectedDay',
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed:
                              _isAdjusting ? null : () => adjustSalesForDay(1)),
                    ])
                  ]),
            ),

            // Manual set remaining
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                  onPressed: setRemainingQuantityManually,
                  child: const Text('Set remaining manually')),
            ),

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
