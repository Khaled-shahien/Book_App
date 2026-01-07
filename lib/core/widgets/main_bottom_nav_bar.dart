import 'package:book_app/features/account/account_page.dart';
import 'package:book_app/features/cart/cart_page.dart';
import 'package:book_app/features/category/categories_page.dart';
import 'package:book_app/features/home/home_view.dart';
import 'package:book_app/core/controllers/nav_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
      HomeView(),
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
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          )),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: 0,
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
                            tween: Tween(
                              begin: 0,
                              end: isSelected ? 1 : 0,
                            ),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 1 + (value * 0.15),
                                child: Container(
                                  padding: EdgeInsets.all(8 + (value * 2)),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? item.color.withOpacity(0.15)
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

// Alternative Design - Floating Style with Indicator
class FloatingBottomNavBar extends GetView<NavController> {
  const FloatingBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeView(),
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
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          )),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 68,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // مؤشر متحرك
            Obx(() {
              final index = controller.selectedIndex.value;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                left: (MediaQuery.of(context).size.width - 48) / 4 * index + 12,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 48) / 4,
                  height: 3,
                  decoration: BoxDecoration(
                    color: navItems[index].color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              );
            }),
            // العناصر
            Row(
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
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              transform: Matrix4.identity()
                                ..translate(0.0, isSelected ? -3.0 : 0.0),
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: isSelected ? 28 : 25,
                                color: isSelected
                                    ? item.color
                                    : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: isSelected ? 11.5 : 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? item.color
                                    : Colors.grey.shade500,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative Design 2 - Minimal with Bubble Effect
class BubbleBottomNavBar extends GetView<NavController> {
  const BubbleBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeView(),
      const CategoriesPage(),
      const CartPage(),
      const AccountPage(),
    ];

    final List<NavItem> navItems = [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        color: const Color(0xFF7C4DFF),
      ),
      NavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'Explore',
        color: const Color(0xFFE91E63),
      ),
      NavItem(
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'Cart',
        color: const Color(0xFFFF9800),
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        color: const Color(0xFF00BCD4),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            return Obx(() {
              final isSelected = controller.selectedIndex.value == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.changeIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                item.color.withOpacity(0.3),
                                item.color.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: isSelected ? 26 : 24,
                          color: isSelected ? item.color : Colors.grey.shade600,
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            });
          }),
        ),
      ),
    );
  }
}