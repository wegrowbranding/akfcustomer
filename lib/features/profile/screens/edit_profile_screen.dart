import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});
  final dynamic profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _gender;

  final Color primaryColor = const Color(0xFFE91E63);
  final Color secondaryColor = const Color(0xFFF06292);
  final Color backgroundColor = const Color(0xFFF9F6F2);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _gender = widget.profile.gender.isNotEmpty ? widget.profile.gender : 'male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -50,
            right: -50,
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
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildAvatarSection(),
                          const SizedBox(height: 40),

                          _buildSectionLabel('IDENTITY'),
                          const SizedBox(height: 12),
                          _buildField(
                            'Full Name',
                            _nameController,
                            Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 24),
                          _buildSectionLabel('CONTACT'),
                          const SizedBox(height: 12),
                          _buildField(
                            'Phone Number',
                            _phoneController,
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 24),
                          _buildSectionLabel('PREFERENCE'),
                          const SizedBox(height: 12),
                          _buildDropdown(),

                          const SizedBox(height: 48),
                          _buildSaveButton(profileProvider, authProvider),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              StringConstants.appName,
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'Serif',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildAvatarSection() => Center(
    child: Stack(
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
          child: const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      letterSpacing: 2,
      fontWeight: FontWeight.w800,
      color: Colors.black38,
    ),
  );

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.2)),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
    ),
  );

  Widget _buildDropdown() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: DropdownButtonFormField<String>(
      initialValue: _gender,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.black.withValues(alpha: 0.2),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.wc_outlined, color: primaryColor, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
      items: ['male', 'female', 'other']
          .map(
            (g) => DropdownMenuItem(
              value: g,
              child: Text(
                g.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _gender = val!),
    ),
  );

  Widget _buildSaveButton(
    ProfileProvider profileProvider,
    AuthProvider authProvider,
  ) => GestureDetector(
    onTap: profileProvider.isLoading
        ? null
        : () async {
            if (_formKey.currentState!.validate()) {
              final success = await profileProvider.editProfile(
                authProvider.token!,
                _nameController.text,
                _phoneController.text,
                _gender,
              );
              if (success && mounted) {
                Navigator.pop(context);
                AppSnackBar.show(
                  context,
                  message: 'Profile updated successfully',
                  type: SnackBarType.success,
                );
              }
            }
          },
    child: Container(
      height: 65,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: profileProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'SAVE CHANGES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
      ),
    ),
  );
}
