import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
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
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<ProfileProvider>().fetchProfile(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final token = authProvider.token;

    if (token == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = profileProvider.profile;

    // Auto-fetch if data is missing but token is available
    if (profile == null && !profileProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileProvider.fetchProfile(token);
      });
    }

    if (profileProvider.error != null && profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: primaryColor),
              const SizedBox(height: 16),
              Text(profileProvider.error!),
              TextButton(
                onPressed: () => profileProvider.fetchProfile(token),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

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
                : RefreshIndicator(
                    onRefresh: () async => profileProvider.fetchProfile(token),
                    color: primaryColor,
                    child: Column(
                      children: [
                        _buildHeader(context, profile),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileCard(
                                  profile,
                                  profileProvider,
                                  token,
                                ),
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
                                        builder: (_) => const OrderListScreen(
                                          popNeeded: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildMenuItem(
                                    Icons.location_on_outlined,
                                    StringConstants.shippingAddresses,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AddressListScreen(),
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
                                        builder: (_) =>
                                            const SupportDetailScreen(
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
                                        builder: (_) =>
                                            const SupportDetailScreen(
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
                                        builder: (_) =>
                                            const SupportDetailScreen(
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
                                        builder: (_) =>
                                            const SupportDetailScreen(
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

  Future<void> _pickImage(
    ImageSource source,
    ProfileProvider provider,
    String token,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null && mounted) {
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        final success = await provider.updateProfilePhoto(token, base64Image);
        if (success && mounted) {
          AppSnackBar.show(
            context,
            message: 'Profile photo updated',
            type: SnackBarType.success,
          );
        } else if (mounted) {
          AppSnackBar.show(
            context,
            message: provider.error ?? 'Failed to update photo',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Error picking image: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  void _showImagePickerOptions(
    ProfileProvider provider,
    String token,
    dynamic profile,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, provider, token);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, provider, token);
                  },
                ),
                if (profile?.profileImage != null)
                  _buildPickerOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove',
                    color: Colors.redAccent,
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await provider.deleteProfilePhoto(token);
                      if (success && mounted) {
                        AppSnackBar.show(
                          context,
                          message: 'Photo removed',
                          type: SnackBarType.success,
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) => Column(
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (color ?? primaryColor).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? primaryColor, size: 28),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black87,
        ),
      ),
    ],
  );

  Widget _buildProfileCard(
    dynamic profile,
    ProfileProvider provider,
    String token,
  ) => Container(
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
              child: GestureDetector(
                onTap: () => _showImagePickerOptions(provider, token, profile),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: backgroundColor,
                  backgroundImage: profile?.profileImage != null
                      ? NetworkImage(
                          ApiConstants.storageUrl(profile!.profileImage!),
                        )
                      : const NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => _showImagePickerOptions(provider, token, profile),
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
