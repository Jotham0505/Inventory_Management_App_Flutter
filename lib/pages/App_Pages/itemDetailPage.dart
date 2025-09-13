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
  // Primary brand green and soft background greens used for UI
  static const Color brandGreen = Color(0xFF17CF73);
  static const Color softMint = Color(0xFFEAF9F0);
  static const double cornerRadius = 16.0;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late int remainingQuantity;
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

    // optimistic UI
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
        final qty = jsonBody['quantity'];
        final int serverQty =
            qty is int ? qty : int.tryParse(qty.toString()) ?? prevRemaining;

        final salesMap = (jsonBody['sales'] ?? {}) as Map<String, dynamic>;
        final salesVal = salesMap[dateStr];
        final int serverSales = salesVal is int
            ? salesVal
            : int.tryParse(salesVal.toString()) ?? prevSales;

        setState(() {
          remainingQuantity = serverQty;
          salesForSelectedDay = serverSales;
        });
      } else {
        // revert and notify
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Set Remaining Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(hintText: 'Enter remaining quantity'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brandGreen),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Set', style: TextStyle(color: Colors.white)),
          ),
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
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: item.id,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24)),
                      child: Image.asset(
                        widget.imagePath,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(24)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.18)
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Overlapping card with title/subtitle & chip
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: -40,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                widget.imagePath,
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(item.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                  //const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Remaining chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: softMint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Column(
                                children: [
                                  Text('Remaining',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[800])),
                                  const SizedBox(height: 2),
                                  Text('$remainingQuantity',
                                      style: const TextStyle(
                                          color: brandGreen,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 56),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: const Color(0xFFEAF9F0), // subtle greenish background
                  elevation: 8, // a bit more lift
                  shadowColor: Colors.black12, // soft shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: const TextStyle(
                              fontSize: 14, height: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _infoChipFixed(
                        icon: Icons.inventory_2,
                        title: 'Price',
                        value: '₹${item.price.toStringAsFixed(2)}'),
                    const SizedBox(width: 12),
                    _infoChipFixed(
                        icon: Icons.local_shipping,
                        title: 'Supplier',
                        value: 'OLAND TEA'),
                    const SizedBox(width: 12),
                    _infoChipFixed(
                        icon: Icons.layers,
                        title: 'Qty',
                        value: '$remainingQuantity'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cornerRadius)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Text('Sales Management',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            // quick range pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: const Text('2 weeks',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ),

                      // calendar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
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
                              color: brandGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            defaultTextStyle:
                                const TextStyle(color: Colors.black87),
                            weekendTextStyle:
                                const TextStyle(color: Colors.black54),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle:
                                TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const Divider(height: 1, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Sales on ${_dateKey(_selectedDay ?? DateTime.now())}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                _iconPillButton(
                                  icon: Icons.remove,
                                  color: brandGreen,
                                  onTap: _isAdjusting
                                      ? null
                                      : () => adjustSalesForDay(-1),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 56,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                            scale: anim, child: child),
                                    child: Text(
                                      '$salesForSelectedDay',
                                      key: ValueKey<int>(salesForSelectedDay),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: brandGreen),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _iconPillButton(
                                  icon: Icons.add,
                                  color: brandGreen,
                                  onTap: _isAdjusting
                                      ? null
                                      : () => adjustSalesForDay(1),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: setRemainingQuantityManually,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  child: const Text('Set Remaining Manually',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconPillButton(
      {required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _infoChipFixed(
      {required IconData icon, required String title, required String value}) {
    const double chipHeight = 90;
    //const double chipWidth = 60;

    return Expanded(
      child: Container(
        height: chipHeight,
        //width: chipWidth,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: softMint, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 20, color: brandGreen),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600)),
                  //const SizedBox(height: 6),

                  Text(
                    value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
