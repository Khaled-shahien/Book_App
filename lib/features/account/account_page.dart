import 'package:book_app/core/auth/auth_error_mapper.dart';
import 'package:book_app/core/auth/session_service.dart';
import 'package:book_app/core/controllers/nav_controller.dart';
import 'package:book_app/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    final user = currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        userData = doc.data();
      } catch (e, st) {
        AppLogger.reportError(e, st, reason: 'load user profile failed');
      }
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      await SessionService.signOut();
    } catch (e, st) {
      AppLogger.reportError(e, st, reason: 'logout failed');
      Get.snackbar(
        'Error',
        'Could not log out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      _loggingOut = false;
    }
  }

  String _getDisplayName() {
    final name = userData?['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    final displayName = currentUser?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    return 'User';
  }

  String _getEmail() {
    return currentUser?.email ?? 'No email';
  }

  String _getInitials() {
    final parts = _getDisplayName()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return '$first$second'.toUpperCase();
  }

  String _stat(String key) {
    final value = userData?[key];
    return value is num ? value.toInt().toString() : '0';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // App Bar مع صورة البروفايل
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.find<NavController>().changeIndex(0);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'My Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                          Colors.purple.shade900,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: Text(
                              _getInitials(),
                              semanticsLabel: _getDisplayName(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // معلومات المستخدم
                  _buildInfoCard(),

                  const SizedBox(height: 20),

                  // قائمة الإعدادات
                  _buildSettingsSection(context),

                  const SizedBox(height: 20),

                  // الإحصائيات
                  _buildStatsSection(),

                  const SizedBox(height: 20),

                  // زر تسجيل الخروج
                  _buildLogoutButton(context),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Name', _getDisplayName()),
          const Divider(height: 30),
          _buildInfoRow(Icons.email_outlined, 'Email', _getEmail()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            color: Colors.blue,
            onTap: () {
              _comingSoon();
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notifications',
            color: Colors.orange,
            onTap: () {
              _comingSoon();
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Password and privacy',
            color: Colors.green,
            onTap: () {
              _comingSoon();
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            color: Colors.purple,
            onTap: () {
              _comingSoon();
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help',
            color: Colors.teal,
            onTap: () {
              _comingSoon();
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            color: Colors.red,
            onTap: _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Coming soon'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and profile data. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await AccountDeletionService.deleteCurrentUser();
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Could not delete account',
        e.code == 'requires-recent-login'
            ? 'For security, please log out, sign in again, then retry.'
            : AuthErrorMapper.message(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      AppLogger.reportError(e, st, reason: 'delete account failed');
      Get.snackbar(
        'Could not delete account',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag_outlined,
            value: _stat('ordersCount'),
            label: 'Orders',
            color: Colors.blue,
          ),
          Container(height: 60, width: 1, color: Colors.grey[300]),
          _buildStatItem(
            icon: Icons.favorite_outline,
            value: _stat('favoritesCount'),
            label: 'Favorites',
            color: Colors.red,
          ),
          Container(height: 60, width: 1, color: Colors.grey[300]),
          _buildStatItem(
            icon: Icons.star_outline,
            value: _stat('reviewsCount'),
            label: 'Reviews',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
