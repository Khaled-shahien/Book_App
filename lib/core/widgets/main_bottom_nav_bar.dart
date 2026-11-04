import 'package:book_app/core/controllers/nav_controller.dart';
import 'package:book_app/features/account/account_page.dart';
import 'package:book_app/features/cart/cart_page.dart';
import 'package:book_app/features/category/categories_page.dart';
import 'package:book_app/features/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

class ModernBottomNavBar extends GetView<NavController> {
  const ModernBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const CategoriesPage(),
      const CartPage(),
      const AccountPage(),
    ];

    final List<NavItem> navItems = [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        color: const Color(0xFF6C63FF),
      ),
      NavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'Categories',
        color: const Color(0xFFFF6B9D),
      ),
      NavItem(
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'Cart',
        color: const Color(0xFFFFA726),
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Account',
        color: const Color(0xFF26C6DA),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              return Obx(() {
                final isSelected = controller.selectedIndex.value == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeIndex(index),
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // أيقونة مع تأثير انيميشن
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: isSelected ? 1 : 0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 1 + (value * 0.15),
                                child: Container(
                                  padding: EdgeInsets.all(8 + (value * 2)),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? item.color.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    size: 26,
                                    color: isSelected
                                        ? item.color
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          // النص مع تأثير fade
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isSelected ? 1.0 : 0.6,
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: isSelected ? 12 : 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? item.color
                                    : Colors.grey.shade500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            }),
          ),
        ),
      ),
    );
  }
}
