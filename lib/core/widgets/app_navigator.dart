import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppNavigator {
  /// Push (Cupertino style)
  static Future<T?> push<T>(BuildContext context, Widget page) =>
      Navigator.push<T>(context, CupertinoPageRoute(builder: (_) => page));

  /// Push (Material style)
  static Future<T?> pushMaterial<T>(BuildContext context, Widget page) =>
      Navigator.push<T>(context, MaterialPageRoute(builder: (_) => page));

  /// Push Replacement
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page) =>
      Navigator.pushReplacement<T, TO>(
        context,
        CupertinoPageRoute(builder: (_) => page),
      );

  /// Push Named
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => Navigator.pushNamed<T>(context, routeName, arguments: arguments);

  /// Push Replacement Named
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => Navigator.pushReplacementNamed<T, TO>(
    context,
    routeName,
    arguments: arguments,
  );

  /// Push and Remove Until (clear stack)
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) =>
      Navigator.pushAndRemoveUntil<T>(
        context,
        CupertinoPageRoute(builder: (_) => page),
        (route) => false,
      );

  /// Push Named and Remove Until
  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => Navigator.pushNamedAndRemoveUntil<T>(
    context,
    routeName,
    (route) => false,
    arguments: arguments,
  );

  /// Pop
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}
