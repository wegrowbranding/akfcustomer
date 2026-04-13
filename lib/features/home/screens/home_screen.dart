import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/login_prompt.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../orders/screens/order_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../shopping/screens/cart_screen.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).fetchUnreadCount(authProvider.token!);
      }
    });
  }

  // Design tokens matching the "Pro" Look
  final Color backgroundColor = const Color(0xFFF8F9FA); // Off-white/Cream
  final Color accentColor = const Color(0xFFE91E63); // Sage Green
  final Color textColor = const Color(0xFF1A1A1A);

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductListScreen(popNeeded: false),
    const CartScreen(),
    const OrderListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint('HOME SCREEN BUILD TRIGGERED');
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element (Consistent with Auth screens)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Premium Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            StringConstants.appName,
                            style: TextStyle(
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Serif',
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (authProvider.isAuthenticated) ...[
                            Consumer<NotificationProvider>(
                              builder: (context, notificationProvider, child) =>
                                  _buildHeaderIcon(
                                    icon: Icons.notifications_none_rounded,
                                    badgeCount:
                                        notificationProvider.unreadCount,
                                    onTap: () =>
                                        context.push(AppRoutes.notifications),
                                  ),
                            ),
                            const SizedBox(width: 12),
                            _buildHeaderIcon(
                              icon: Icons.favorite_border_rounded,
                              onTap: () => context.push(AppRoutes.wishlist),
                            ),
                          ],
                          const SizedBox(width: 12),
                          _buildHeaderIcon(
                            icon: authProvider.isAuthenticated
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                            onTap: () {
                              if (authProvider.isAuthenticated) {
                                authProvider.logout();
                              }
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Custom Floating-style Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(color: backgroundColor),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(
                  1,
                  Icons.grid_view_rounded,
                  Icons.grid_view_rounded,
                  'Shop',
                ),
                _buildNavItem(
                  2,
                  Icons.shopping_bag_outlined,
                  Icons.shopping_bag,
                  'Cart',
                ),
                _buildNavItem(
                  3,
                  Icons.receipt_long_outlined,
                  Icons.receipt_long,
                  'History',
                ),
                _buildNavItem(
                  4,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Icon(icon, size: 20, color: accentColor),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index > 1 && !authProvider.isAuthenticated) {
          LoginPrompt.show(context);
          return;
        }
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
