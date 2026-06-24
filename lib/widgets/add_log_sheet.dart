import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_log.dart';

class AddLogSheet extends StatefulWidget {
  const AddLogSheet({super.key, this.initialLog});

  final WorkoutLog? initialLog;

  @override
  State<AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends State<AddLogSheet> {
  late final TextEditingController _weightController;
  late final TextEditingController _totalRepsController;
  late final TextEditingController _setsController;
  late bool _canLog;

  bool get _isEditing => widget.initialLog != null;

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
    _setsController = TextEditingController(
      text: log != null ? '${log.sets}' : '',
    );
    _canLog = log != null;
    for (final c in [_weightController, _totalRepsController, _setsController]) {
      c.addListener(_onChanged);
    }
  }

  String _stripTrailingZero(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    for (final c in [_weightController, _totalRepsController, _setsController]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    final can = _weightController.text.trim().isNotEmpty &&
        _totalRepsController.text.trim().isNotEmpty &&
        _setsController.text.trim().isNotEmpty;
    if (can != _canLog) setState(() => _canLog = can);
  }

  void _submit() {
    final weight = double.tryParse(_weightController.text.trim());
    final totalReps = int.tryParse(_totalRepsController.text.trim());
    final sets = int.tryParse(_setsController.text.trim());
    if (weight == null || totalReps == null || sets == null) return;
    if (weight <= 0 || totalReps <= 0 || sets <= 0) return;
    Navigator.pop(
      context,
      WorkoutLog(
        date: widget.initialLog?.date ?? DateTime.now(),
        weight: weight,
        totalReps: totalReps,
        sets: sets,
      ),
    );
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
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _InputField(
                  label: 'WEIGHT',
                  hint: '0',
                  suffix: 'lbs',
                  controller: _weightController,
                  decimal: true,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _InputField(
                  label: 'TOTAL REPS',
                  hint: '0',
                  controller: _totalRepsController,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _InputField(
                  label: 'SETS',
                  hint: '0',
                  controller: _setsController,
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
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
