// widgets/category_card.dart
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final Color color;
  final String count;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 150;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                _buildBackgroundCircle(isSmall),
                _buildContent(isSmall),
                _buildArrowIndicator(isSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundCircle(bool isSmall) {
    return Positioned(
      right: -20,
      top: -20,
      child: Container(
        width: isSmall ? 60 : 80,
        height: isSmall ? 60 : 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildContent(bool isSmall) {
    return Padding(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: _buildIcon(isSmall)),
          const SizedBox(height: 8),
          Flexible(child: _buildInfo(isSmall)),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(icon, style: TextStyle(fontSize: isSmall ? 20 : 28)),
    );
  }

  Widget _buildInfo(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isSmall ? 13 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: isSmall ? 10 : 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'books',
                style: TextStyle(
                  fontSize: isSmall ? 10 : 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIndicator(bool isSmall) {
    return Positioned(
      right: 8,
      bottom: 8,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 4 : 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: isSmall ? 10 : 12,
          color: color,
        ),
      ),
    );
  }
}