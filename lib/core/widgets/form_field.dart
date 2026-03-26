import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    required this.label,
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.contentPadding,
  });
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final void Function()? onSuffixTap;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    maxLines: maxLines,
    maxLength: maxLength,
    enabled: enabled,
    textInputAction: textInputAction,
    focusNode: focusNode,
    onTap: onTap,
    onChanged: onChanged,
    onFieldSubmitted: (_) {
      if (nextFocusNode != null) {
        FocusScope.of(context).requestFocus(nextFocusNode);
      }
    },
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null
          ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap)
          : null,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.pink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),
    style: const TextStyle(fontSize: 16, color: Colors.black87),
  );
}

class CustomValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'\d'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
