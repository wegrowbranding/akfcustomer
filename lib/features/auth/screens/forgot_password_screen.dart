import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _serverOtp;

  // Design tokens matching the "Pro" Look
  final Color backgroundColor = AppTheme.backgroundColor;
  final Color accentColor = AppTheme.primaryColor;
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkEmail() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.checkEmailExists(
        _emailController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      if (response['success'] == true && response['data'] != null) {
        if (response['data']['exists'] == true) {
          _serverOtp = response['data']['otp'].toString();
          setState(() {
            _currentStep = ForgotPasswordStep.otp;
          });
        } else {
          AppSnackBar.show(
            context,
            message: 'Email does not exist.',
            type: SnackBarType.error,
          );
        }
      } else {
        AppSnackBar.show(
          context,
          message: response['message'] ?? 'Error checking email',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim() == _serverOtp) {
      setState(() {
        _currentStep = ForgotPasswordStep.newPassword;
      });
    } else {
      AppSnackBar.show(
        context,
        message: 'Invalid OTP',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        AppSnackBar.show(
          context,
          message: 'Passwords do not match',
          type: SnackBarType.error,
        );
        return;
      }

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.changePassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      if (response.success) {
        AppSnackBar.show(
          context,
          message: 'Password changed successfully',
          type: SnackBarType.success,
        );
        context.go(AppRoutes.login);
      } else {
        AppSnackBar.show(
          context,
          message: response.message,
          type: SnackBarType.error,
        );
      }
    }
  }

  void _handleNextStep() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        _checkEmail();
        break;
      case ForgotPasswordStep.otp:
        _verifyOtp();
        break;
      case ForgotPasswordStep.newPassword:
        _resetPassword();
        break;
    }
  }

  String _getSubtitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return StringConstants.enterEmailToReset;
      case ForgotPasswordStep.otp:
        return StringConstants.enterOtpSubtitle;
      case ForgotPasswordStep.newPassword:
        return StringConstants.setNewPasswordSubtitle;
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return StringConstants.verifyEmailButton;
      case ForgotPasswordStep.otp:
        return StringConstants.verifyOtpButton;
      case ForgotPasswordStep.newPassword:
        return StringConstants.resetPasswordButton;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back Button
                    IconButton(
                      onPressed: () {
                        if (_currentStep == ForgotPasswordStep.email) {
                          context.pop();
                        } else if (_currentStep == ForgotPasswordStep.otp) {
                          setState(() {
                            _currentStep = ForgotPasswordStep.email;
                          });
                        } else {
                          setState(() {
                            _currentStep = ForgotPasswordStep.otp;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 20),

                    // Brand Identity
                    Text(
                      StringConstants.appName.toUpperCase(),
                      style: const TextStyle(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Editorial Heading
                    Text(
                      StringConstants.resetPasswordTitle,
                      style: TextStyle(
                        fontSize: 48,
                        height: 1.1,
                        fontWeight: FontWeight.w300,
                        color: textColor,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getSubtitle(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Input Fields based on current step
                    if (_currentStep == ForgotPasswordStep.email) ...[
                      _buildTextField(
                        controller: _emailController,
                        label: StringConstants.emailLabel,
                        hint: 'nature@akflowers.com',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ] else if (_currentStep == ForgotPasswordStep.otp) ...[
                      _buildTextField(
                        controller: _otpController,
                        label: StringConstants.otpLabel,
                        hint: '123456',
                        icon: Icons.lock_clock_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'OTP is required';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      _buildTextField(
                        controller: _passwordController,
                        label: StringConstants.newPasswordLabel,
                        hint: '••••••••',
                        isPassword: true,
                        icon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 characters required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: StringConstants.confirmPasswordLabel,
                        hint: '••••••••',
                        isPassword: true,
                        icon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm password';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Action Button
                    GestureDetector(
                      onTap: authProvider.isLoading ? null : _handleNextStep,
                      child: Container(
                        height: 65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _getButtonText(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.2)),
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentColor),
          ),
          errorStyle: const TextStyle(fontSize: 11),
        ),
        validator: validator,
      ),
    ],
  );
}
