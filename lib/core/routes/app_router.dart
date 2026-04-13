import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/product_detail_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/orders/screens/order_list_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/shopping/screens/cart_screen.dart';
import '../../features/shopping/screens/wishlist_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider authProvider) => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.onboarding,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isGuest = authProvider.isGuest;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isRegistering = state.matchedLocation == AppRoutes.register;
      final isForgotPassword = state.matchedLocation == AppRoutes.forgotPassword;

      final isAuthPage =
          isLoggingIn || isRegistering || isOnboarding || isForgotPassword;

      final isPublicRoute =
          state.matchedLocation == AppRoutes.home ||
          state.matchedLocation.startsWith(AppRoutes.productDetail);

      // If not authenticated and not a guest and not on auth pages, go to onboarding/login
      if (!isAuthenticated && !isGuest && !isAuthPage && !isPublicRoute) {
        return AppRoutes.onboarding;
      }

      // If authenticated or guest and on auth pages, go to home
      if ((isAuthenticated || isGuest) && isAuthPage) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.productDetail}/:productId',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: int.parse(productId));
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.matchedLocation}'),
      ),
    ),
  );
}
