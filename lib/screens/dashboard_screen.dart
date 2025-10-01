import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    double totalIncome = transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    double totalExpense = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    double balance = totalIncome - totalExpense;

    final categoryTotals = <String, double>{};
    for (var t in transactions.where((t) => t.isExpense)) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Balance",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      balance.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text("Income",
                                style: TextStyle(color: Colors.green)),
                            Text("+${totalIncome.toStringAsFixed(2)}"),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Expenses",
                                style: TextStyle(color: Colors.red)),
                            Text("-${totalExpense.toStringAsFixed(2)}"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pie Chart
            Text("Expenses by Category",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 200, child: _CategoryPieChart()),

            const SizedBox(height: 20),

            // Weekly Spending Chart
            Text("Weekly Spending",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 200, child: _WeeklyChart()),
          ],
        ),
      ),
    );
  }
}

/// Pie Chart Widget
class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    final categoryTotals = <String, double>{};
    for (var t in transactions.where((t) => t.isExpense)) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final sections = categoryTotals.entries.map((e) {
      return PieChartSectionData(
        title: e.key,
        value: e.value,
        color: Colors.primaries[categoryTotals.keys.toList().indexOf(e.key) %
            Colors.primaries.length],
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return PieChart(PieChartData(
      sections: sections,
      centerSpaceRadius: 40,
      sectionsSpace: 2,
    ));
  }
}

/// Weekly Spending Bar Chart
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: i)));

    final dailyTotals = {for (var i in List.generate(7, (i) => i)) i: 0.0};

    for (var t in transactions.where((t) => t.isExpense)) {
      for (int i = 0; i < 7; i++) {
        if (t.date.day == last7Days[i].day &&
            t.date.month == last7Days[i].month &&
            t.date.year == last7Days[i].year) {
          dailyTotals[i] = dailyTotals[i]! + t.amount;
        }
      }
    }

    return BarChart(
      BarChartData(
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyTotals[i]!,
                color: Colors.blue,
                width: 14,
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final weekday = [
                  "Sun",
                  "Mon",
                  "Tue",
                  "Wed",
                  "Thu",
                  "Fri",
                  "Sat"
                ];
                return Text(weekday[value.toInt() % 7]);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
