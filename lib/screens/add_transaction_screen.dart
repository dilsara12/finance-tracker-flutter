import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  bool _isExpense = true;
  String _selectedCategory = "";

  late Box<CategoryModel> _categoryBox;

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<CategoryModel>('categories');

    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _isExpense = widget.transaction!.isExpense;
      _selectedCategory = widget.transaction!.category;
    } else {
      _selectedDate = DateTime.now();

      if (_categoryBox.isNotEmpty)
        _selectedCategory = _categoryBox.getAt(0)!.name;
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedCategory.isNotEmpty) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);

      if (widget.transaction == null) {
        provider.addTransaction(
          TransactionModel(
            title: _titleController.text,
            amount: double.parse(_amountController.text),
            date: _selectedDate!,
            isExpense: _isExpense,
            category: _selectedCategory,
          ),
        );
      } else {
        widget.transaction!
          ..title = _titleController.text
          ..amount = double.parse(_amountController.text)
          ..date = _selectedDate!
          ..isExpense = _isExpense
          ..category = _selectedCategory;
        provider.updateTransaction(widget.transaction!);
      }

      Navigator.pop(context);
    }
  }

  void _addCategory() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Category name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _categoryBox.add(CategoryModel(
                    name: controller.text, isExpense: _isExpense));
                setState(() => _selectedCategory = controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null
        ? DateFormat("yMMMd").format(_selectedDate!)
        : "No date chosen";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null
            ? "Add Transaction"
            : "Edit Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter title" : null,
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter amount" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text("Date: $dateText")),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory.isEmpty
                            ? null
                            : _selectedCategory,
                        items: _categoryBox.values
                            .map((cat) => DropdownMenuItem(
                                  value: cat.name,
                                  child: Text(cat.name),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                        decoration:
                            const InputDecoration(labelText: "Category"),
                        validator: (val) => val == null || val.isEmpty
                            ? "Select category"
                            : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addCategory,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Is Expense?"),
                  value: _isExpense,
                  onChanged: (val) => setState(() => _isExpense = val),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text(widget.transaction == null ? "Add" : "Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
