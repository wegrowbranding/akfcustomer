import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/string_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class SupportDetailScreen extends StatefulWidget {
  const SupportDetailScreen({
    required this.title,
    required this.metaKey,
    super.key,
  });
  final String title;
  final String metaKey;

  @override
  State<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  String? _content;
  bool _isLoading = true;
  String? _error;

  final Color primaryColor = const Color(0xFFE91E63);
  final Color secondaryColor = const Color(0xFFF06292);
  final Color backgroundColor = const Color(0xFFF9F6F2);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchContent();
    });
  }

  Future<void> _fetchContent() async {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();

    if (auth.token != null) {
      final content = await profile.fetchSupportMeta(
        auth.token!,
        widget.metaKey,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _content = content;
        _isLoading = false;
        _error = profile.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : _error != null
                    ? _buildErrorState()
                    : _buildContentScroll(),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              StringConstants.appName,
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              widget.title,
              style: const TextStyle(
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

  Widget _buildContentScroll() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual Accent Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'GUIDE & INFORMATION',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Main Body Content
        Container(
          padding: const EdgeInsets.all(4),
          child: Text(
            _content ??
                'No content available at this time. Our florists are working on updating our records.',
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
              color: textColor.withValues(alpha: 0.75),
              letterSpacing: 0.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Contact Support Section
        Center(
          child: Column(
            children: [
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 32),
              Text(
                'STILL HAVE QUESTIONS?',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  const phone = '+916374545878';
                  final Uri uri = Uri.parse('tel:$phone');
                  if (!await launchUrl(uri)) {
                    throw 'Could not call $phone';
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'CONTACT THE BOUTIQUE',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: primaryColor.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _error ?? 'Unable to retrieve information',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Serif',
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _fetchContent,
            child: Text(
              'REFRESH CONTENT',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
