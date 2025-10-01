import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final Box<CategoryModel> _categoryBox = Hive.box<CategoryModel>('categories');

  List<CategoryModel> get categories => _categoryBox.values.toList();

  void addCategory(CategoryModel category) {
    _categoryBox.add(category);
    notifyListeners();
  }

  void deleteCategory(CategoryModel category) {
    category.delete();
    notifyListeners();
  }

  void updateCategory(CategoryModel category) {
    category.save();
    notifyListeners();
  }
}
