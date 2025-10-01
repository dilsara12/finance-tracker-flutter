import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class BarChartWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const BarChartWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<int, double> dailyTotals = {
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0
    };

    for (var tx in transactions) {
      if (tx.isExpense) {
        dailyTotals[tx.date.weekday - 1] =
            (dailyTotals[tx.date.weekday - 1] ?? 0) + tx.amount;
      }
    }

    final barGroups = dailyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blueAccent,
            width: 18,
          )
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                return Text(days[value.toInt() % 7]);
              },
            ),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }
}
