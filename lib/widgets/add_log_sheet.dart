import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';

class AddLogSheet extends StatefulWidget {
  const AddLogSheet({
    super.key,
    required this.exerciseType,
    this.isBodyweightOnly = false,
    this.initialLog,
  });

  final ExerciseType exerciseType;
  final bool isBodyweightOnly;
  final WorkoutLog? initialLog;

  @override
  State<AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends State<AddLogSheet> {
  // ── Workout inputs ──────────────────────────────────────────────
  late final TextEditingController _weightController;
  late final TextEditingController _totalRepsController;
  late final FixedExtentScrollController _hoursController;
  late final FixedExtentScrollController _minutesController;
  late final FixedExtentScrollController _secondsController;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _isHoursMode = false;
  late bool _canLog;

  // ── Date selection ──────────────────────────────────────────────
  late final DateTime _today;
  bool _isDifferentDay = false;
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedYear;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _yearController;

  bool get _isEditing => widget.initialLog != null;
  bool get _isTimeBased => widget.exerciseType == ExerciseType.timeBased;
  bool get _isBodyweight => widget.isBodyweightOnly;

  @override
  void initState() {
    super.initState();
    final log = widget.initialLog;
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);

    // ── Date init ──
    _selectedYear = _today.year;
    _selectedMonth = _today.month;
    _selectedDay = _today.day;

    if (log != null) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (logDate.isBefore(_today)) {
        _selectedYear = log.date.year;
        _selectedMonth = log.date.month;
        _selectedDay = log.date.day;
      }
    }

    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayController =
        FixedExtentScrollController(initialItem: _selectedDay - 1);
    _yearController =
        FixedExtentScrollController(initialItem: _today.year - _selectedYear);

    // ── Workout input init ──
    _weightController = TextEditingController(
      text: log != null ? _stripTrailingZero(log.weight) : '',
    );
    _totalRepsController = TextEditingController(
      text: log != null ? '${log.totalReps}' : '',
    );

    if (log?.totalTime != null) {
      if (log!.isHoursUsed) {
        _isHoursMode = true;
        _hours = log.totalTime! ~/ 3600;
        _minutes = (log.totalTime! % 3600) ~/ 60;
        _seconds = log.totalTime! % 60;
      } else {
        _minutes = log.totalTime! ~/ 60;
        _seconds = log.totalTime! % 60;
      }
    }

    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(initialItem: _minutes);
    _secondsController = FixedExtentScrollController(initialItem: _seconds);

    _canLog = log != null;
    for (final c in _activeControllers) {
      c.addListener(_onChanged);
    }
  }

  List<TextEditingController> get _activeControllers {
    if (_isTimeBased && _isBodyweight) return [];
    if (_isTimeBased) return [_weightController];
    if (_isBodyweight) return [_totalRepsController];
    return [_weightController, _totalRepsController];
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    for (final c in [_weightController, _totalRepsController]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Date helpers ────────────────────────────────────────────────

  int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  int _maxMonth(int year) =>
      year == _today.year ? _today.month : 12;

  int _maxDay(int year, int month) {
    final calMax = _daysInMonth(year, month);
    if (year == _today.year && month == _today.month) {
      return _today.day < calMax ? _today.day : calMax;
    }
    return calMax;
  }

  DateTime get _selectedDate {
    if (!_isDifferentDay) return widget.initialLog?.date ?? DateTime.now();
    return DateTime(_selectedYear, _selectedMonth, _selectedDay);
  }

  void _onDifferentDayChanged(bool value) {
    if (value) {
      final log = widget.initialLog;
      final logDate = log != null
          ? DateTime(log.date.year, log.date.month, log.date.day)
          : null;
      if (logDate != null && logDate.isBefore(_today)) {
        _selectedYear = logDate.year;
        _selectedMonth = logDate.month;
        _selectedDay = logDate.day;
      } else {
        _selectedYear = _today.year;
        _selectedMonth = _today.month;
        _selectedDay = _today.day;
      }
    } else {
      _selectedYear = _today.year;
      _selectedMonth = _today.month;
      _selectedDay = _today.day;
    }
    if (_yearController.hasClients) {
      _yearController.jumpToItem(_today.year - _selectedYear);
    }
    if (_monthController.hasClients) {
      _monthController.jumpToItem(_selectedMonth - 1);
    }
    if (_dayController.hasClients) {
      _dayController.jumpToItem(_selectedDay - 1);
    }
    setState(() => _isDifferentDay = value);
  }

  void _onYearChanged(int index) {
    setState(() {
      _selectedYear = _today.year - index;
      final maxM = _maxMonth(_selectedYear);
      if (_selectedMonth > maxM) {
        _selectedMonth = maxM;
        if (_monthController.hasClients) {
          _monthController.jumpToItem(_selectedMonth - 1);
        }
      }
      final maxD = _maxDay(_selectedYear, _selectedMonth);
      if (_selectedDay > maxD) {
        _selectedDay = maxD;
        if (_dayController.hasClients) {
          _dayController.jumpToItem(_selectedDay - 1);
        }
      }
    });
  }

  void _onMonthChanged(int index) {
    setState(() {
      _selectedMonth = index + 1;
      final maxD = _maxDay(_selectedYear, _selectedMonth);
      if (_selectedDay > maxD) {
        _selectedDay = maxD;
        if (_dayController.hasClients) {
          _dayController.jumpToItem(_selectedDay - 1);
        }
      }
    });
  }

  void _onDayChanged(int index) => setState(() => _selectedDay = index + 1);

  // ── Workout helpers ─────────────────────────────────────────────

  void _onChanged() {
    final controllersOk =
        _activeControllers.every((c) => c.text.trim().isNotEmpty);
    final totalSecs = _hours * 3600 + _minutes * 60 + _seconds;
    final timeOk = !_isTimeBased || totalSecs > 0;
    final can = controllersOk && timeOk;
    if (can != _canLog) setState(() => _canLog = can);
  }

  void _onHoursModeChanged(bool value) {
    if (!value) {
      _hours = 0;
      if (_hoursController.hasClients) _hoursController.jumpToItem(0);
    }
    setState(() => _isHoursMode = value);
    _onChanged();
  }

  String _stripTrailingZero(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  void _submit() {
    final totalTime = _hours * 3600 + _minutes * 60 + _seconds;
    final date = _selectedDate;

    if (_isTimeBased && _isBodyweight) {
      if (totalTime <= 0) return;
      Navigator.pop(context,
          WorkoutLog(date: date, weight: 0, totalTime: totalTime, isHoursUsed: _isHoursMode));
    } else if (_isTimeBased) {
      final weight = double.tryParse(_weightController.text.trim());
      if (weight == null || weight <= 0 || totalTime <= 0) return;
      Navigator.pop(context,
          WorkoutLog(date: date, weight: weight, totalTime: totalTime, isHoursUsed: _isHoursMode));
    } else if (_isBodyweight) {
      final totalReps = int.tryParse(_totalRepsController.text.trim());
      if (totalReps == null || totalReps <= 0) return;
      Navigator.pop(context,
          WorkoutLog(date: date, weight: 0, totalReps: totalReps));
    } else {
      final weight = double.tryParse(_weightController.text.trim());
      final totalReps = int.tryParse(_totalRepsController.text.trim());
      if (weight == null || totalReps == null) return;
      if (weight <= 0 || totalReps <= 0) return;
      Navigator.pop(context,
          WorkoutLog(date: date, weight: weight, totalReps: totalReps));
    }
  }

  // ── Date picker widget ──────────────────────────────────────────

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  Widget _buildDatePicker() {
    const pickerHeight = 180.0;
    const itemExtent = 46.0;
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w400,
    );

    Widget wheel({
      required FixedExtentScrollController controller,
      required int childCount,
      required Widget Function(int) builder,
      required void Function(int) onChanged,
    }) {
      return CupertinoPicker.builder(
        scrollController: controller,
        itemExtent: itemExtent,
        childCount: childCount,
        onSelectedItemChanged: onChanged,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: const Color(0xFF6C63FF).withValues(alpha: 0.12),
        ),
        itemBuilder: (_, i) => Center(child: builder(i)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: pickerHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Month
              Expanded(
                flex: 4,
                child: wheel(
                  controller: _monthController,
                  childCount: _maxMonth(_selectedYear),
                  builder: (i) => Text(_months[i], style: textStyle),
                  onChanged: _onMonthChanged,
                ),
              ),
              // Day
              Expanded(
                flex: 2,
                child: wheel(
                  controller: _dayController,
                  childCount: _maxDay(_selectedYear, _selectedMonth),
                  builder: (i) => Text('${i + 1}', style: textStyle),
                  onChanged: _onDayChanged,
                ),
              ),
              // Year
              Expanded(
                flex: 3,
                child: wheel(
                  controller: _yearController,
                  childCount: 11,
                  builder: (i) =>
                      Text('${_today.year - i}', style: textStyle),
                  onChanged: _onYearChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Text(
                  'month',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'day',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  'year',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 28),
          // Title + "Different Day?" pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing ? 'Edit Log' : 'Log Workout',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _onDifferentDayChanged(!_isDifferentDay),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isDifferentDay
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isDifferentDay
                          ? const Color(0xFF6C63FF).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Different Day?',
                    style: TextStyle(
                      color: _isDifferentDay
                          ? const Color(0xFF6C63FF)
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isDifferentDay) ...[
            const SizedBox(height: 20),
            _buildDatePicker(),
          ],
          const SizedBox(height: 28),
          if (_isTimeBased && _isBodyweight)
            _TimePicker(
              isHoursMode: _isHoursMode,
              hoursController: _hoursController,
              minutesController: _minutesController,
              secondsController: _secondsController,
              onHoursModeChanged: _onHoursModeChanged,
              onHoursChanged: (v) { _hours = v; _onChanged(); },
              onMinutesChanged: (v) { _minutes = v; _onChanged(); },
              onSecondsChanged: (v) { _seconds = v; _onChanged(); },
            )
          else if (_isTimeBased)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InputField(
                  label: 'WEIGHT (lbs)',
                  hint: '0',
                  suffix: 'lbs',
                  controller: _weightController,
                  decimal: true,
                ),
                const SizedBox(height: 16),
                _TimePicker(
                  isHoursMode: _isHoursMode,
                  hoursController: _hoursController,
                  minutesController: _minutesController,
                  secondsController: _secondsController,
                  onHoursModeChanged: _onHoursModeChanged,
                  onHoursChanged: (v) { _hours = v; _onChanged(); },
                  onMinutesChanged: (v) { _minutes = v; _onChanged(); },
                  onSecondsChanged: (v) { _seconds = v; _onChanged(); },
                ),
              ],
            )
          else if (_isBodyweight)
            _InputField(
              label: 'TOTAL REPS',
              hint: '0',
              controller: _totalRepsController,
              onSubmitted: (_) => _submit(),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _InputField(
                    label: 'WEIGHT (lbs)',
                    hint: '0',
                    suffix: 'lbs',
                    controller: _weightController,
                    decimal: true,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: _InputField(
                    label: 'TOTAL REPS',
                    hint: '0',
                    controller: _totalRepsController,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AnimatedOpacity(
              opacity: _canLog ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 150),
              child: ElevatedButton(
                onPressed: _canLog ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  disabledBackgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Log Workout',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time picker ─────────────────────────────────────────────────────

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.isHoursMode,
    required this.hoursController,
    required this.minutesController,
    required this.secondsController,
    required this.onHoursModeChanged,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  final bool isHoursMode;
  final FixedExtentScrollController hoursController;
  final FixedExtentScrollController minutesController;
  final FixedExtentScrollController secondsController;
  final ValueChanged<bool> onHoursModeChanged;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;

  static const _itemExtent = 46.0;
  static const _pickerHeight = 180.0;

  Widget _linearWheel(
    FixedExtentScrollController controller,
    int itemCount,
    ValueChanged<int> onChanged, {
    bool padded = true,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: _itemExtent,
      looping: false,
      backgroundColor: Colors.transparent,
      onSelectedItemChanged: onChanged,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: const Color(0xFF6C63FF).withValues(alpha: 0.12),
      ),
      children: List.generate(
        itemCount,
        (i) => Center(
          child: Text(
            padded ? i.toString().padLeft(2, '0') : '$i',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _minutesWheel() {
    return CupertinoPicker.builder(
      scrollController: minutesController,
      itemExtent: _itemExtent,
      onSelectedItemChanged: onMinutesChanged,
      childCount: 1000,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: const Color(0xFF6C63FF).withValues(alpha: 0.12),
      ),
      itemBuilder: (_, index) => Center(
        child: Text(
          isHoursMode ? index.toString().padLeft(2, '0') : '$index',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _colon() => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          ':',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 28,
            fontWeight: FontWeight.w200,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL TIME',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: () => onHoursModeChanged(!isHoursMode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHoursMode
                      ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHoursMode
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Hours',
                  style: TextStyle(
                    color: isHoursMode
                        ? const Color(0xFF6C63FF)
                        : Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: _pickerHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (isHoursMode) ...[
                Expanded(
                  key: const ValueKey('hours'),
                  child: _linearWheel(hoursController, 24, onHoursChanged),
                ),
                _colon(),
              ],
              Expanded(
                key: const ValueKey('minutes'),
                child: _minutesWheel(),
              ),
              _colon(),
              Expanded(
                key: const ValueKey('seconds'),
                child: _linearWheel(secondsController, 60, onSecondsChanged),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (isHoursMode) ...[
              Expanded(
                child: Center(
                  child: Text(
                    'hr',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
            Expanded(
              child: Center(
                child: Text(
                  'min',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Center(
                child: Text(
                  'sec',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Text input field ────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.suffix,
    this.decimal = false,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? suffix;
  final bool decimal;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          inputFormatters: [
            if (decimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: const Color(0xFF6C63FF),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 16,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
