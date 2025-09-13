import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tea_app/models/task_model.dart';

class ProfilePage extends StatefulWidget {
  final String profileImageUrl;
  final String name;
  final String role;
  final String email;
  final String phone;
  final String address;
  final String lastLogin;
  final List<String> recentActions;
  final int itemsAdded;
  final int ordersProcessed;
  final double salesContributed;
  final bool isLoading; // set true while fetching from backend
  final double monthlyGoal; // left in place if you want later
  final List<Task> toDoList; // change the type from Map to Task

  const ProfilePage({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.address,
    required this.lastLogin,
    required this.recentActions,
    required this.itemsAdded,
    required this.ordersProcessed,
    required this.salesContributed,
    this.isLoading = false,
    this.monthlyGoal = 60000,
    this.toDoList = const [],
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum _ChartRange { daily, weekly, monthly }

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF17CF73);

  late final AnimationController _shimmerController;
  _ChartRange _selectedRange = _ChartRange.daily;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Hello';
  }

  // quick helper to show SnackBar
  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  // When long-pressing quick actions -> haptic + help text
  void _onQuickActionLongPress(String label) {
    HapticFeedback.lightImpact();
    _showSnack(label);
  }

  // ---------------- Chart data generators ----------------
  // These create placeholder deterministic data based on salesContributed
  List<double> _makeDaily() {
    // 7 days
    final base = max(50.0, widget.salesContributed / 7.0);
    return List.generate(
      7,
      (i) => (base * (0.6 + i * 0.06)).roundToDouble(),
    );
  }

  List<double> _makeWeekly() {
    // 4 weeks
    final base = max(200.0, widget.salesContributed / 4.0);
    return List.generate(
      4,
      (i) => (base * (0.8 + i * 0.10)).roundToDouble(),
    );
  }

  List<double> _makeMonthly() {
    // 12 months
    final base = max(700.0, widget.salesContributed / 12.0);
    return List.generate(
      12,
      (i) => (base * (0.7 + (i % 4) * 0.12)).roundToDouble(),
    );
  }

  List<String> _labelsForRange(_ChartRange r) {
    if (r == _ChartRange.daily) {
      final now = DateTime.now();
      return List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        return _weekdayShort(d.weekday);
      });
    } else if (r == _ChartRange.weekly) {
      return ['Week1', 'Week2', 'Week3', 'Week4'];
    } else {
      final now = DateTime.now();
      return List.generate(12, (i) {
        final dt = DateTime(now.year, now.month - 11 + i);
        return _monthShort(dt.month);
      });
    }
  }

  String _weekdayShort(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1) % 7];
  }

  String _monthShort(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[(m - 1) % 12];
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final bg = Colors.grey[50];
    final titleStyle = const TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final subtitleStyle = TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 14,
      color: Colors.grey[700],
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: titleStyle),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Hook for real refresh
              _showSnack('Refreshing...');
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isLoading)
                    _buildHeaderShimmer()
                  else
                    _buildHeader(),
                  const SizedBox(height: 16),
                  if (!widget.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${_greeting()}, ${widget.name.split(' ').first} 👋',
                        style: const TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!widget.isLoading) const SizedBox(height: 8),
                  if (widget.isLoading)
                    _buildAnalyticsShimmer()
                  else
                    _buildAnalyticsCardWithBar(titleStyle, subtitleStyle),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Actions',
                    style: const TextStyle(
                      fontFamily: 'Epilogue',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.isLoading)
                    ...List.generate(3, (i) => _listTileShimmer())
                  else
                    ...widget.recentActions.take(5).map((a) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.1),
                            ),
                            child: Icon(Icons.check_circle,
                                color: primaryColor, size: 20),
                          ),
                          title: Text(
                            a,
                            style: const TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right,
                              size: 18, color: Colors.grey[400]),
                          onTap: () {
                            // optional: show details of action
                          },
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 18),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: primaryColor.withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upcoming Tasks',
                            style: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // show list of tasks (pull from backend or local DB)
                          ...widget.toDoList.map((task) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                leading: Checkbox(
                                  activeColor: primaryColor,
                                  value: task.isDone,
                                  onChanged: (val) {
                                    setState(() {
                                      task.isDone = val!;
                                    });
                                  },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'Due: ${DateFormat('dd MMM yyyy').format(task.dueDate)}',
                                  style: const TextStyle(
                                      fontFamily: 'Epilogue',
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                                trailing: Icon(Icons.more_vert,
                                    color: Colors.grey[400]),
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 12),
                          // Add Task
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              onPressed: () {
                                _showAddTaskDialog();
                              },
                              icon: const Icon(Icons.add,
                                  size: 18, color: Colors.white),
                              label: const Text(
                                'Add Task',
                                style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add New Task',
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style:
                        const TextStyle(fontFamily: 'Epilogue', fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(
                        fontFamily: 'Epilogue',
                        color: Colors.black,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          icon: Icon(Icons.date_range, color: Colors.black),
                          label: Text(
                            selectedDate == null
                                ? 'Select Due Date'
                                : DateFormat('dd MMM yyyy')
                                    .format(selectedDate!),
                            style: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                // optional themed date picker
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setStateDialog(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    selectedDate == null) {
                  return;
                }
                setState(() {
                  widget.toDoList.add(Task(
                    title: titleController.text.trim(),
                    dueDate: selectedDate!,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCardWithBar(
      TextStyle titleStyle, TextStyle subtitleStyle) {
    // determine data
    final List<double> values = (_selectedRange == _ChartRange.daily)
        ? _makeDaily()
        : (_selectedRange == _ChartRange.weekly)
            ? _makeWeekly()
            : _makeMonthly();

    final List<String> labels = _labelsForRange(_selectedRange);

    final maxY = (values.isEmpty) ? 1.0 : (values.reduce(max) * 1.15);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: primaryColor.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // segmented control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Trend',
                  style: const TextStyle(
                    fontFamily: 'Epilogue',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  isSelected: [
                    _selectedRange == _ChartRange.daily,
                    _selectedRange == _ChartRange.weekly,
                    _selectedRange == _ChartRange.monthly
                  ],
                  onPressed: (i) {
                    setState(() {
                      _selectedRange = (i == 0)
                          ? _ChartRange.daily
                          : (i == 1)
                              ? _ChartRange.weekly
                              : _ChartRange.monthly;
                    });
                  },
                  selectedColor: Colors.white,
                  fillColor: primaryColor,
                  color: Colors.black87,
                  constraints:
                      const BoxConstraints(minHeight: 34, minWidth: 64),
                  children: const [
                    Text('Daily', style: TextStyle(fontFamily: 'Epilogue')),
                    Text('Weekly', style: TextStyle(fontFamily: 'Epilogue')),
                    Text('Monthly', style: TextStyle(fontFamily: 'Epilogue')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Chart area
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // border radius & padding options
                      tooltipBorderRadius: BorderRadius.circular(6),
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      // fit inside if needed
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      // provide tooltip content
                      getTooltipItem: (BarChartGroupData group, int groupIndex,
                          BarChartRodData rod, int rodIndex) {
                        final value = rod.toY;
                        final label = (group.x.toInt() < labels.length)
                            ? labels[group.x.toInt()]
                            : '';
                        return BarTooltipItem(
                          '$label\n₹ ${value.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Epilogue',
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          // simple safe widget (works across fl_chart versions)
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[i],
                              style: const TextStyle(
                                fontFamily: 'Epilogue',
                                fontSize: 8,
                              ),
                            ),
                          );
                        },
                        interval: 1,
                        reservedSize: 36,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        // you can provide a getTitlesWidget for left axis too if needed
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(values.length, (i) {
                    final v = values[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: v,
                          width:
                              (_selectedRange == _ChartRange.monthly) ? 12 : 18,
                          borderRadius: BorderRadius.circular(6),
                          color: primaryColor,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    );
                  }),
                  alignment: BarChartAlignment.spaceEvenly,
                  groupsSpace: 0,
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // small stats row remains
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('Items', widget.itemsAdded.toString()),
                _statColumn('Orders', widget.ordersProcessed.toString()),
                _statColumn(
                    'Sales ₹', widget.salesContributed.toStringAsFixed(0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            )),
        const SizedBox(height: 4),
        Text(title,
            style: TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 12,
              color: Colors.grey[700],
            )),
      ],
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // gradient background card
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.95),
                  primaryColor.withOpacity(0.78)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(140, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name,
                          style: const TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(widget.role,
                              style: const TextStyle(
                                  fontFamily: 'Epilogue',
                                  fontSize: 13,
                                  color: Colors.white70)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Verified',
                                style: TextStyle(
                                    fontFamily: 'Epilogue',
                                    color: Colors.white,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.email,
                          style: const TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 13,
                              color: Colors.white70)),
                    ],
                  ),
                ),
                // edit button
                GestureDetector(
                  onTap: () {
                    _showSnack('Open edit profile');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // overlapping avatar
          Positioned(
            left: 16,
            top: 40,
            child: Hero(
              tag: 'profile-avatar',
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    _showSnack('Open avatar viewer');
                  },
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(widget.profileImageUrl),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // shimmer gradient background
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 40,
            child: _shimmerCircle(52),
          ),
          // text bars
          Positioned(
            left: 140,
            top: 36,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBar(width: 160, height: 18),
                const SizedBox(height: 8),
                _shimmerBar(width: 120, height: 14),
                const SizedBox(height: 8),
                _shimmerBar(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsShimmer() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              _shimmerBar(width: 88, height: 88, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _shimmerBar(width: double.infinity, height: 14),
                    const SizedBox(height: 12),
                    _shimmerBar(width: double.infinity, height: 14),
                    const SizedBox(height: 12),
                    _shimmerBar(width: double.infinity, height: 14),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _shimmerBar(width: 64, height: 16),
              _shimmerBar(width: 64, height: 16),
              _shimmerBar(width: 64, height: 16),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _listTileShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _shimmerCircle(12),
          const SizedBox(width: 12),
          _shimmerBar(width: 240, height: 12),
        ],
      ),
    );
  }

  Widget _shimmerBar(
      {double width = double.infinity, double height = 12, double radius = 6}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 - _shimmerController.value * 2, 0),
              end: Alignment(1 + _shimmerController.value * 2, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(rect);
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          blendMode: BlendMode.srcATop,
        );
      },
    );
  }

  Widget _shimmerCircle(double size) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 - _shimmerController.value * 2, 0),
              end: Alignment(1 + _shimmerController.value * 2, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(rect);
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          blendMode: BlendMode.srcATop,
        );
      },
    );
  }
}
