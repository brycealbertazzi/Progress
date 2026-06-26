import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';
import '../screens/day_detail_screen.dart';

class CalendarSheet extends StatefulWidget {
  const CalendarSheet({super.key, required this.exercises});

  /// All exercises including their loaded logs.
  final List<Exercise> exercises;

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late DateTime _month;
  late Map<String, List<({WorkoutLog log, Exercise exercise})>> _logsByDate;

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _buildIndex();
  }

  @override
  void didUpdateWidget(CalendarSheet old) {
    super.didUpdateWidget(old);
    _buildIndex();
  }

  void _buildIndex() {
    _logsByDate = {};
    for (final exercise in widget.exercises) {
      for (final log in exercise.logs) {
        final key = _key(log.date);
        _logsByDate.putIfAbsent(key, () => []);
        _logsByDate[key]!.add((log: log, exercise: exercise));
      }
    }
  }

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get _canGoForward {
    final now = DateTime.now();
    return _month.year < now.year ||
        (_month.year == now.year && _month.month < now.month);
  }

  int get _daysInMonth =>
      DateTime(_month.year, _month.month + 1, 0).day;

  // 0 = Sunday, 6 = Saturday (Dart weekday: 1=Mon, 7=Sun)
  int get _firstWeekday =>
      DateTime(_month.year, _month.month, 1).weekday % 7;

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1, 1));

  void _nextMonth() {
    if (_canGoForward) {
      setState(() => _month = DateTime(_month.year, _month.month + 1, 1));
    }
  }

  void _onDayTap(int day) {
    final date = DateTime(_month.year, _month.month, day);
    final entries = _logsByDate[_key(date)];
    if (entries == null || entries.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayDetailScreen(date: date, entries: entries),
      ),
    ).then((_) {
      if (mounted) setState(() => _buildIndex());
    });
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return _month.year == now.year &&
        _month.month == now.month &&
        day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final rows = ((_firstWeekday + _daysInMonth) / 7).ceil();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Cell size = available width minus horizontal padding, divided by 7 columns
        final cellSize = (constraints.maxWidth - 24) / 7;
        final gridHeight = rows * cellSize;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildMonthHeader(),
              const SizedBox(height: 16),
              _buildWeekdayRow(),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: gridHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: rows * 7,
                    itemBuilder: (_, index) {
                      final day = index - _firstWeekday + 1;
                      if (day < 1 || day > _daysInMonth) return const SizedBox();

                      final hasLogs = _logsByDate.containsKey(
                          _key(DateTime(_month.year, _month.month, day)));

                      return _DayCell(
                        day: day,
                        hasLogs: hasLogs,
                        isToday: _isToday(day),
                        onTap: hasLogs ? () => _onDayTap(day) : null,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: bottomPadding + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: _prevMonth,
          ),
          Expanded(
            child: Text(
              '${_monthNames[_month.month - 1]} ${_month.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _canGoForward ? Colors.white : Colors.white24,
              size: 28,
            ),
            onPressed: _canGoForward ? _nextMonth : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _weekdayLabels.map((label) {
          return Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.hasLogs,
    required this.isToday,
    this.onTap,
  });

  final int day;
  final bool hasLogs;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: isToday
            ? BoxDecoration(
                border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: hasLogs ? Colors.white : Colors.white.withValues(alpha: 0.2),
                fontSize: 15,
                fontWeight: hasLogs ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            if (hasLogs)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
