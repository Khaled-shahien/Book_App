// widgets/category_chips.dart
import 'package:flutter/material.dart';
import 'package:book_app/features/home/data/controllers/book_controller.dart';

class CategoryChips extends StatefulWidget {
  final BookController controller;
  const CategoryChips({super.key, required this.controller});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  static const _categories = [
    'All',
    'Fiction',
    'Science',
    'History',
    'Technology',
    'Art',
  ];
  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B9D),
    Color(0xFF4CAF50),
    Color(0xFFFFA726),
    Color(0xFF26C6DA),
    Color(0xFF9C27B0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (c, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _buildChip(index),
      ),
    );
  }

  Widget _buildChip(int index) {
    final isSelected = widget.controller.selectedCategoryIndex.value == index;
    return GestureDetector(
      onTap: () => _onChipTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [_colors[index], _colors[index].withOpacity(0.7)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _colors[index].withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _categories[index],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _onChipTap(int index) {
    // Update the controller's selected category first
    widget.controller.selectedCategoryIndex.value = index;

    // Then fetch books based on the selected category
    widget.controller.searchBooks(index > 0 ? _categories[index] : 'books');
  }
}
