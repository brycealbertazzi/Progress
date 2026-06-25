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
  late final FixedExtentScrollController _minutesController;
  late final FixedExtentScrollController _secondsController;
  int _minutes = 0;
  int _seconds = 0;
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
      _minutes = log!.totalTime! ~/ 60;
      _seconds = log.totalTime! % 60;
    }
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
    final timeOk = !_isTimeBased || (_minutes * 60 + _seconds) > 0;
    final can = controllersOk && timeOk;
    if (can != _canLog) setState(() => _canLog = can);
  }

  String _stripTrailingZero(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  void _submit() {
    final totalTime = _minutes * 60 + _seconds;

    if (_isTimeBased && _isBodyweight) {
      if (totalTime <= 0) return;
      Navigator.pop(
        context,
        WorkoutLog(
          date: widget.initialLog?.date ?? DateTime.now(),
          weight: 0,
          totalTime: totalTime,
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
              minutesController: _minutesController,
              secondsController: _secondsController,
              onMinutesChanged: (v) {
                _minutes = v;
                _onChanged();
              },
              onSecondsChanged: (v) {
                _seconds = v;
                _onChanged();
              },
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
                  minutesController: _minutesController,
                  secondsController: _secondsController,
                  onMinutesChanged: (v) {
                    _minutes = v;
                    _onChanged();
                  },
                  onSecondsChanged: (v) {
                    _seconds = v;
                    _onChanged();
                  },
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
    required this.minutesController,
    required this.secondsController,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  final FixedExtentScrollController minutesController;
  final FixedExtentScrollController secondsController;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;

  static const _itemExtent = 46.0;
  static const _pickerHeight = 180.0;

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
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _secondsWheel() {
    return CupertinoPicker(
      scrollController: secondsController,
      itemExtent: _itemExtent,
      looping: true,
      backgroundColor: Colors.transparent,
      onSelectedItemChanged: onSecondsChanged,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: const Color(0xFF6C63FF).withValues(alpha: 0.12),
      ),
      children: List.generate(
        60,
        (i) => Center(
          child: Text(
            i.toString().padLeft(2, '0'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 8),
        Container(
          height: _pickerHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(child: _minutesWheel()),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Expanded(child: _secondsWheel()),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
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
