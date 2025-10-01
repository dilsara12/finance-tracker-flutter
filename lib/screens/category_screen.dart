import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: categories.isEmpty
          ? const Center(child: Text("No categories yet. Add some!"))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (ctx, index) {
                final category = categories[index];
                return ListTile(
                  leading: Icon(
                    category.isExpense ? Icons.remove_circle : Icons.add_circle,
                    color: category.isExpense ? Colors.red : Colors.green,
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showCategoryDialog(context, provider, category);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteCategory(category);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showCategoryDialog(context, provider, null);
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, CategoryProvider provider,
      CategoryModel? category) {
    final TextEditingController nameController =
        TextEditingController(text: category?.name ?? "");
    bool isExpense = category?.isExpense ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category == null ? "Add Category" : "Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            Row(
              children: [
                const Text("Type: "),
                DropdownButton<bool>(
                  value: isExpense,
                  items: const [
                    DropdownMenuItem(value: true, child: Text("Expense")),
                    DropdownMenuItem(value: false, child: Text("Income")),
                  ],
                  onChanged: (val) {
                    isExpense = val!;
                  },
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              if (category == null) {
                provider.addCategory(CategoryModel(
                    name: nameController.text.trim(), isExpense: isExpense));
              } else {
                category.name = nameController.text.trim();
                category.isExpense = isExpense;
                provider.updateCategory(category);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
