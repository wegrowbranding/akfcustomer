import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';

import '../../auth/providers/auth_provider.dart';
import '../../orders/screens/order_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../shopping/screens/cart_screen.dart';
import '../../shopping/screens/wishlist_screen.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
                          _buildHeaderIcon(
                            icon: Icons.favorite_border_rounded,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WishlistScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderIcon(
                            icon: Icons.logout_rounded,
                            onTap: () {
                              authProvider.logout();
                              Navigator.pushReplacementNamed(context, '/login');
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
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, size: 20, color: accentColor),
    ),
  );

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
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
