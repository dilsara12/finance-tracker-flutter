import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final Box<TransactionModel> _transactionBox =
      Hive.box<TransactionModel>('transactions');

  List<TransactionModel> get transactions => _transactionBox.values.toList();

  void addTransaction(TransactionModel transaction) {
    _transactionBox.add(transaction);
    notifyListeners();
  }

  void deleteTransaction(TransactionModel transaction) {
    transaction.delete(); // Hive delete
    notifyListeners();
  }

  void updateTransaction(TransactionModel transaction) {
    transaction.save(); // Hive save after editing
    notifyListeners();
  }
}
