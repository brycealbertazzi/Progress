import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';

class VolumeChartSheet extends StatelessWidget {
  const VolumeChartSheet({super.key, required this.exercise});

  final Exercise exercise;

  bool get _isTimeBased => exercise.exerciseType == ExerciseType.timeBased;

  @override
  Widget build(BuildContext context) {
    final logs = [...exercise.logs]..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
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
          const SizedBox(height: 24),
          Text(
            exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isTimeBased ? 'Total Duration (sec)' : 'Total Volume (lbs)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(child: _buildChart(logs)),
        ],
      ),
    );
  }

  List<({DateTime date, double volume})> _aggregateByDay(List<WorkoutLog> logs) {
    final map = <String, ({DateTime date, double volume})>{};
    for (final log in logs) {
      final key = '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}';
      final current = map[key];
      map[key] = (date: log.date, volume: (current?.volume ?? 0) + log.volume);
    }
    return map.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Widget _buildChart(List<WorkoutLog> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'No data yet',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    final daily = _aggregateByDay(logs);

    final spots = daily
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.volume))
        .toList();

    final maxY = daily.map((d) => d.volume).reduce((a, b) => a > b ? a : b);
    final minY = daily.map((d) => d.volume).reduce((a, b) => a < b ? a : b);
    final yPadding = (maxY - minY) * 0.2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (daily.length - 1).toDouble(),
        minY: (minY - yPadding).clamp(0, double.infinity),
        maxY: maxY + yPadding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF6C63FF),
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF6C63FF),
                strokeWidth: 2,
                strokeColor: const Color(0xFF1A1A1A),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.2),
                  const Color(0xFF6C63FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: _niceInterval(minY, maxY),
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  _formatY(value),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _xLabelInterval(daily.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= daily.length) return const SizedBox.shrink();
                final date = daily[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _niceInterval(minY, maxY),
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2C2C3E),
            getTooltipItems: (spots) => spots.map((s) {
              final day = daily[s.x.toInt()];
              final valueLabel = _isTimeBased
                  ? _formatTime(s.y.toInt())
                  : '${_formatY(s.y)} lbs';
              return LineTooltipItem(
                '${_formatDate(day.date)}\n',
                const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
                children: [
                  TextSpan(
                    text: valueLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  double _xLabelInterval(int count) {
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    return (count / 4).ceilToDouble();
  }

  double _niceInterval(double min, double max) {
    final range = (max - min).abs();
    if (_isTimeBased) {
      if (range <= 0) return 15;
      final rough = range / 4;
      const steps = [5.0, 10.0, 15.0, 30.0, 60.0, 120.0, 300.0];
      return steps.firstWhere((s) => s >= rough, orElse: () => 300);
    }
    if (range <= 0) return 500;
    final rough = range / 4;
    const steps = [100.0, 200.0, 250.0, 500.0, 1000.0, 2000.0, 2500.0, 5000.0];
    return steps.firstWhere((s) => s >= rough, orElse: () => 5000);
  }

  String _formatY(double v) {
    if (_isTimeBased) return _formatTime(v.toInt());
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toInt().toString();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }
}
