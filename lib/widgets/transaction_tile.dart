import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../screens/add_transaction_screen.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Transaction"),
            content:
                const Text("Are you sure you want to delete this transaction?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat("yMMMd").format(transaction.date);

    return Dismissible(
      key: ValueKey(transaction.key),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) =>
          _confirmDelete(context), // ✅ confirmation before delete
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.isExpense ? Colors.red : Colors.green,
            child: Icon(
              transaction.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
          title: Text(transaction.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${transaction.category} • $dateFormatted"),
          trailing: Text(
            "Rs. ${transaction.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: transaction.isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTransactionScreen(transaction: transaction)),
          ),
        ),
      ),
    );
  }
}
