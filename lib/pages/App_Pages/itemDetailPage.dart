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
  final Color brandGreen = const Color(0xFF17CF73);

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
        setState(() {
          remainingQuantity = jsonBody['quantity'] ?? remainingQuantity;
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
        setState(() {
          salesForSelectedDay = jsonBody['count'] ?? 0;
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

    final prevRemaining = remainingQuantity;
    final prevSales = salesForSelectedDay;

    setState(() {
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
        final jsonBody = jsonDecode(res.body);

        final qtyRaw = jsonBody['quantity'];
        final int serverQty = qtyRaw is int
            ? qtyRaw
            : (qtyRaw is num
                ? qtyRaw.toInt()
                : int.tryParse(qtyRaw?.toString() ?? '') ?? remainingQuantity);

        final salesMapRaw = (jsonBody['sales'] ?? {}) as Map<String, dynamic>;
        final dynamic salesValRaw = salesMapRaw[dateStr];
        final int serverSales = salesValRaw is int
            ? salesValRaw
            : (salesValRaw is num
                ? salesValRaw.toInt()
                : int.tryParse(salesValRaw?.toString() ?? '') ??
                    salesForSelectedDay);

        setState(() {
          remainingQuantity = serverQty;
          salesForSelectedDay = serverSales;
        });
      } else {
        setState(() {
          remainingQuantity = prevRemaining;
          salesForSelectedDay = prevSales;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update sales')),
        );
      }
    } catch (e) {
      setState(() {
        remainingQuantity = prevRemaining;
        salesForSelectedDay = prevSales;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Network error')));
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
        title: const Text('Set Remaining Quantity'),
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
              child: Text('Set', style: TextStyle(color: brandGreen))),
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
        setState(() => remainingQuantity = jsonBody['quantity'] ?? newQty);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Quantity updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to set quantity')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error setting quantity')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: item.id,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.asset(
                    widget.imagePath,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.description,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Details'),
              _buildDetailTile('Remaining', '$remainingQuantity'),
              _buildDetailTile('Price', '₹${item.price.toStringAsFixed(2)}'),
              _buildDetailTile('Supplier', 'OLAND TEA'),
              _buildSectionTitle('Sales Management'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 2,
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
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: brandGreen,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: brandGreen.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales on ${_dateKey(_selectedDay ?? DateTime.now())}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: brandGreen),
                          onPressed:
                              _isAdjusting ? null : () => adjustSalesForDay(-1),
                        ),
                        Text('$salesForSelectedDay'),
                        IconButton(
                          icon:
                              Icon(Icons.add_circle_outline, color: brandGreen),
                          onPressed:
                              _isAdjusting ? null : () => adjustSalesForDay(1),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: setRemainingQuantityManually,
                  child: const Text(
                    'Set Remaining Manually',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return ListTile(
      dense: true,
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: brandGreen, fontWeight: FontWeight.w600),
      ),
    );
  }
}
