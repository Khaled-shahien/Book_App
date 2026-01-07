// categories_page.dart
import 'package:flutter/material.dart';
import 'widgets/category_app_bar.dart';
import 'widgets/category_card.dart';
import 'widgets/category_books_view.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const _categories = [
    {'name': 'Fiction', 'icon': '📚', 'color': 0xFFFF6B9D, 'count': '2,450'},
    {'name': 'Science', 'icon': '🔬', 'color': 0xFF4CAF50, 'count': '1,820'},
    {'name': 'History', 'icon': '📜', 'color': 0xFFFFA726, 'count': '1,650'},
    {'name': 'Technology', 'icon': '💻', 'color': 0xFF26C6DA, 'count': '2,100'},
    {'name': 'Art', 'icon': '🎨', 'color': 0xFF9C27B0, 'count': '980'},
    {'name': 'Biography', 'icon': '👤', 'color': 0xFFEF5350, 'count': '1,340'},
    {'name': 'Business', 'icon': '💼', 'color': 0xFF5C6BC0, 'count': '1,890'},
    {'name': 'Psychology', 'icon': '🧠', 'color': 0xFFAB47BC, 'count': '1,520'},
    {'name': 'Philosophy', 'icon': '🤔', 'color': 0xFF78909C, 'count': '890'},
    {'name': 'Romance', 'icon': '💕', 'color': 0xFFEC407A, 'count': '3,200'},
    {'name': 'Mystery', 'icon': '🔍', 'color': 0xFF7E57C2, 'count': '1,750'},
    {'name': 'Fantasy', 'icon': '🐉', 'color': 0xFF42A5F5, 'count': '2,680'},
    {'name': 'Self-Help', 'icon': '✨', 'color': 0xFFFFCA28, 'count': '1,920'},
    {'name': 'Travel', 'icon': '✈️', 'color': 0xFF26A69A, 'count': '1,150'},
    {'name': 'Cooking', 'icon': '🍳', 'color': 0xFFFF7043, 'count': '840'},
    {'name': 'Sports', 'icon': '⚽', 'color': 0xFF66BB6A, 'count': '670'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final bottomSafePadding = MediaQuery.of(context).padding.bottom + 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          const CategoryAppBar(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              screenWidth > 600 ? 24 : 16,
              screenWidth > 600 ? 24 : 16,
              screenWidth > 600 ? 24 : 16,
              (screenWidth > 600 ? 24 : 16) + bottomSafePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: screenWidth > 600 ? 1.3 : 1.2,
                crossAxisSpacing: screenWidth > 600 ? 20 : 12,
                mainAxisSpacing: screenWidth > 600 ? 20 : 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = _categories[index];
                return CategoryCard(
                  name: category['name'] as String,
                  icon: category['icon'] as String,
                  color: Color(category['color'] as int),
                  count: category['count'] as String,
                  onTap: () => _navigateToCategoryBooks(context, category),
                );
              }, childCount: _categories.length),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCategoryBooks(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryBooksPage(
          categoryName: category['name'] as String,
          categoryIcon: category['icon'] as String,
          categoryColor: Color(category['color'] as int),
        ),
      ),
    );
  }
}
