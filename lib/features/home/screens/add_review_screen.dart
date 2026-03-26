import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({required this.productId, super.key});
  final int productId;

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 5;
  final _reviewController = TextEditingController();

  final Color backgroundColor = const Color(0xFFF9F6F2);
  final Color primaryColor = const Color(0xFFE91E63);
  final Color accentColor = const Color(0xFFE91E63); // Sage Green
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void dispose() {
    _reviewController.dispose();
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
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Custom Header with Back Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 24),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const Text(
                        StringConstants.appName,
                        style: TextStyle(
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Editorial Heading
                  Text(
                    'Share your\nExperience',
                    style: TextStyle(
                      fontSize: 40,
                      height: 1.1,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Serif',
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your feedback helps us cultivate a better floral journey for everyone.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Rating Section
                  const Text(
                    'HOW WOULD YOU RATE IT?',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final bool isSelected = i < _rating;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.amber.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 44,
                              color: isSelected ? Colors.amber : Colors.black12,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Review Input Section
                  const Text(
                    'DESCRIBE THE BLOOMS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Talk about the scent, the colors, or the delivery...',
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Submit Button
                  GestureDetector(
                    onTap: profileProvider.isLoading
                        ? null
                        : () async {
                            if (authProvider.token == null) {
                              return;
                            }
                            final success = await profileProvider.addReview(
                              authProvider.token!,
                              widget.productId,
                              _rating,
                              _reviewController.text,
                            );
                            if (success && mounted) {
                              Navigator.pop(context);
                              AppSnackBar.show(
                                context,
                                message: 'Thank you for your impression',
                                type: SnackBarType.success,
                              );
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
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
                                'SUBMIT REVIEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 14,
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
        ],
      ),
    );
  }
}
