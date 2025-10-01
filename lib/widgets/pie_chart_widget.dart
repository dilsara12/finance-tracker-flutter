import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class PieChartWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const PieChartWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};

    for (var tx in transactions) {
      if (tx.isExpense) {
        categoryTotals[tx.category] =
            (categoryTotals[tx.category] ?? 0) + tx.amount;
      }
    }

    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 70,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    if (sections.isEmpty) {
      return const Center(child: Text("No expense data yet."));
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
      ),
    );
  }
}
