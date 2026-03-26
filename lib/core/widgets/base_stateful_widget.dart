import 'package:flutter/material.dart';
import 'app_snackbar.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key});
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading({required bool loading}) {
    setState(() {
      _isLoading = loading;
      if (loading) {
        _errorMessage = null;
      }
    });
  }

  void setError(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
    AppSnackBar.show(context, message: message, type: SnackBarType.error);
  }

  void clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  void showSuccess(String message) {
    AppSnackBar.show(context, message: message, type: SnackBarType.success);
  }

  void showInfo(String message) {
    AppSnackBar.show(context, message: message);
  }

  Widget buildLoadingIndicator() => const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
    ),
  );

  Widget buildErrorWidget(String message, VoidCallback onRetry) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Try Again'),
        ),
      ],
    ),
  );

  Widget buildEmptyState(
    String message, {
    Widget? icon,
    VoidCallback? onAction,
    String? actionText,
  }) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon ??
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        if (onAction != null && actionText != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(actionText),
          ),
        ],
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    onInitState();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void onInitState() {}
  void onDispose() {}
}
