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

  bool get _isEditing => widget.initialLog != null;
  bool get _isTimeBased => widget.exerciseType == ExerciseType.timeBased;
  bool get _isBodyweight => widget.isBodyweightOnly;

  @override
  void initState() {
    super.initState();
    final log = widget.initialLog;

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
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    for (final c in [_weightController, _totalRepsController]) {
      c.dispose();
    }
    super.dispose();
  }

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

    if (_isTimeBased && _isBodyweight) {
      if (totalTime <= 0) return;
      Navigator.pop(
        context,
        WorkoutLog(
          date: widget.initialLog?.date ?? DateTime.now(),
          weight: 0,
          totalTime: totalTime,
          isHoursUsed: _isHoursMode,
        ),
      );
    } else if (_isTimeBased) {
      final weight = double.tryParse(_weightController.text.trim());
      if (weight == null || weight <= 0 || totalTime <= 0) return;
      Navigator.pop(
        context,
        WorkoutLog(
          date: widget.initialLog?.date ?? DateTime.now(),
          weight: weight,
          totalTime: totalTime,
          isHoursUsed: _isHoursMode,
        ),
      );
    } else if (_isBodyweight) {
      final totalReps = int.tryParse(_totalRepsController.text.trim());
      if (totalReps == null || totalReps <= 0) return;
      Navigator.pop(
        context,
        WorkoutLog(
          date: widget.initialLog?.date ?? DateTime.now(),
          weight: 0,
          totalReps: totalReps,
        ),
      );
    } else {
      final weight = double.tryParse(_weightController.text.trim());
      final totalReps = int.tryParse(_totalRepsController.text.trim());
      if (weight == null || totalReps == null) return;
      if (weight <= 0 || totalReps <= 0) return;
      Navigator.pop(
        context,
        WorkoutLog(
          date: widget.initialLog?.date ?? DateTime.now(),
          weight: weight,
          totalReps: totalReps,
        ),
      );
    }
  }

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
          Text(
            _isEditing ? 'Edit Log' : 'Log Workout',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
