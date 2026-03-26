import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/screens/order_list_screen.dart';
import '../../shopping/screens/address_list_screen.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'support_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = AppTheme.primaryColor;
  final Color secondaryColor = AppTheme.secondaryColor;
  final Color backgroundColor = AppTheme.backgroundColor;
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).fetchProfile(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: profileProvider.isLoading && profile == null
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : Column(
                    children: [
                      _buildHeader(context, profile),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileCard(profile),
                              const SizedBox(height: 32),

                              _buildSectionTitle(
                                StringConstants.accountSettings,
                              ),
                              const SizedBox(height: 12),
                              _buildMenuCard([
                                _buildMenuItem(
                                  Icons.shopping_bag_outlined,
                                  StringConstants.orderHistory,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const OrderListScreen(),
                                    ),
                                  ),
                                ),
                                _buildMenuItem(
                                  Icons.location_on_outlined,
                                  StringConstants.shippingAddresses,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddressListScreen(),
                                    ),
                                  ),
                                ),
                              ]),

                              const SizedBox(height: 32),
                              _buildSectionTitle(
                                StringConstants.supportAndInfo,
                              ),
                              const SizedBox(height: 12),
                              _buildMenuCard([
                                _buildMenuItem(
                                  Icons.help_outline_rounded,
                                  StringConstants.helpCenter,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SupportDetailScreen(
                                        title: 'Help Center',
                                        metaKey: 'help-center',
                                      ),
                                    ),
                                  ),
                                ),
                                _buildMenuItem(
                                  Icons.line_axis,
                                  StringConstants.helpFaq,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SupportDetailScreen(
                                        title: 'FAQ',
                                        metaKey: 'faq',
                                      ),
                                    ),
                                  ),
                                ),
                                _buildMenuItem(
                                  Icons.privacy_tip_outlined,
                                  StringConstants.privacyPolicy,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SupportDetailScreen(
                                        title: 'Privacy Policy',
                                        metaKey: 'privacy-policy',
                                      ),
                                    ),
                                  ),
                                ),
                                _buildMenuItem(
                                  Icons.info_outline_rounded,
                                  StringConstants.aboutFlora,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SupportDetailScreen(
                                        title: 'About Us',
                                        metaKey: 'about',
                                      ),
                                    ),
                                  ),
                                ),
                              ]),

                              const SizedBox(height: 32),
                              _buildLogoutButton(authProvider),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, var profile) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          StringConstants.myProfile,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            fontFamily: 'Serif',
            color: Color(0xFF1A1A1A),
          ),
        ),
        IconButton(
          onPressed: () {
            if (profile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(profile: profile),
                ),
              );
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Icon(Icons.edit_outlined, size: 20, color: primaryColor),
          ),
        ),
      ],
    ),
  );

  Widget _buildProfileCard(dynamic profile) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: backgroundColor,
                // Placeholder Unsplash image for a clean portrait look
                backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          profile?.fullName ?? 'Valued Member',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile?.email ?? 'nature@akflowers.com',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (profile?.phone != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile!.phone,
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w800,
        color: Colors.black38,
      ),
    ),
  );

  Widget _buildMenuCard(List<Widget> items) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(children: items),
  );

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      );

  Widget _buildLogoutButton(AuthProvider authProvider) => GestureDetector(
    onTap: () {
      authProvider.logout();
      AppSnackBar.show(context, message: 'Successfully logged out');
      context.go(AppRoutes.login);
    },
    child: Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            StringConstants.logout,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}
