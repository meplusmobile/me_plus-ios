import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleBackHandler extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const RoleBackHandler({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  String _getHomeRoute() {
    if (currentRoute.startsWith('/student/')) {
      return '/student/home';
    } else if (currentRoute.startsWith('/parent/')) {
      return '/parent/home';
    } else if (currentRoute.startsWith('/market-owner/')) {
      return '/market-owner/home';
    }
    // Default fallback (shouldn't happen in normal flow)
    return '/login';
  }

  bool _isHomeRoute() {
    return currentRoute == '/student/home' ||
        currentRoute == '/parent/home' ||
        currentRoute == '/market-owner/home';
  }

  @override
  Widget build(BuildContext context) {
    // Don't intercept back button on home routes
    if (_isHomeRoute()) {
      return child;
    }

    // For non-home routes, redirect to role home page
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final homeRoute = _getHomeRoute();
          if (context.mounted) {
            // Use pushReplacement to replace current route instead of adding new one
            context.pushReplacement(homeRoute);
          }
        }
      },
      child: child,
    );
  }
}
