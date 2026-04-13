import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/fcm_service.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/orders/providers/order_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/shopping/providers/shopping_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final authProvider = AuthProvider(apiService: apiService);

  // Set logout callback
  ApiService.logoutCallback = authProvider.forceLogout;

  await authProvider.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initalize();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiService),
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ShoppingProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ProfileProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              OrderProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              NotificationProvider(apiService: context.read<ApiService>()),
        ),
      ],
      child: MyApp(authProvider: authProvider),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({required this.authProvider, super.key});
  final AuthProvider authProvider;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(widget.authProvider);
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'AK Flowers',
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
  );
}
