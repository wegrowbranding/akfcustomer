import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({required this.productId, super.key});
  final int productId;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Design Tokens
  final Color primaryColor = const Color(0xFFE91E63);
  final Color secondaryColor = const Color(0xFFF06292);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color accentColor = const Color(0xFFE91E63); // Sage Green

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token != null) {
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchProductReviews(token, widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final reviews = profileProvider.productReviews;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Custom Editorial Header
                _buildHeader(context),

                // 2. Reviews Content
                Expanded(
                  child: profileProvider.isLoading && reviews.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : reviews.isEmpty
                      ? _buildEmptyReviews()
                      : _buildReviewsList(reviews),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 24, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 10),
        const Text(
          StringConstants.appName,
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Customer\nImpressions',
          style: TextStyle(
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w300,
            fontFamily: 'Serif',
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    ),
  );

  Widget _buildReviewsList(List<dynamic> reviews) => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    itemCount: reviews.length + 1, // +1 for the Summary Header
    itemBuilder: (context, index) {
      if (index == 0) {
        return _buildRatingSummary();
      }
      final review = reviews[index - 1];
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _ReviewTile(review: review, primaryColor: primaryColor),
      );
    },
  );

  Widget _buildRatingSummary() => Container(
    margin: const EdgeInsets.only(bottom: 32),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Column(
          children: [
            const Text(
              '4.8',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 14,
                  color: i < 4 ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '124 Reviews',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Column(
            children: [
              _buildStarLine(5, 0.8),
              _buildStarLine(4, 0.15),
              _buildStarLine(3, 0.03),
              _buildStarLine(2, 0.01),
              _buildStarLine(1, 0.01),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildStarLine(int star, double progress) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              color: Colors.amber,
              minHeight: 4,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyReviews() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_outlined,
            size: 60,
            color: primaryColor.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No impressions yet',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Be the first to share your floral story.',
          style: TextStyle(color: Colors.black38),
        ),
      ],
    ),
  );

  Widget _buildFab(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddReviewScreen(productId: widget.productId),
        ),
      );
    },
    child: Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Text(
            'SHARE EXPERIENCE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review, required this.primaryColor});
  final dynamic review;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    (review.customer?.fullName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customer?.fullName ?? 'Valued Customer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 10,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Purchase',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Text(
              review.createdAt.split('T')[0],
              style: const TextStyle(
                color: Colors.black26,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              Icons.star,
              size: 16,
              color: i < review.rating ? Colors.amber : Colors.grey.shade200,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          review.review,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
