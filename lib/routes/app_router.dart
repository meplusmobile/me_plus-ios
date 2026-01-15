import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/core/widgets/role_back_handler.dart';
import 'package:me_plus/presentation/screens/splash_check_screen.dart';
import 'package:me_plus/presentation/screens/login_screen.dart';
import 'package:me_plus/presentation/screens/signup_screen.dart';
import 'package:me_plus/presentation/screens/roleselection_screen.dart';
import 'package:me_plus/presentation/screens/market_ownersignup_screen.dart';
import 'package:me_plus/presentation/screens/parentsignup_screen.dart';
import 'package:me_plus/presentation/screens/studentsignup_screen.dart';
import 'package:me_plus/presentation/screens/google_signup_details_screen.dart';
import 'package:me_plus/presentation/screens/onboarding_screen.dart';
import 'package:me_plus/presentation/screens/forgot_password_screen.dart';
import 'package:me_plus/presentation/screens/verify_code_screen.dart';
import 'package:me_plus/presentation/screens/set_new_password_screen.dart';
import 'package:me_plus/presentation/screens/password_change_success_screen.dart';
import 'package:me_plus/presentation/screens/student/student_home_screen.dart';
import 'package:me_plus/presentation/screens/student/store_screen.dart';
import 'package:me_plus/presentation/screens/student/top10_screen.dart';
import 'package:me_plus/presentation/screens/student/notifications_screen.dart';
import 'package:me_plus/presentation/screens/student/activity_screen.dart';
import 'package:me_plus/presentation/screens/student/behavior_screen.dart';
import 'package:me_plus/presentation/screens/student/profile_screen.dart';
import 'package:me_plus/presentation/screens/student/account_screen.dart';
import 'package:me_plus/presentation/screens/student/purchases_screen.dart';
import 'package:me_plus/presentation/screens/student/missing_reward_screen.dart';
import 'package:me_plus/presentation/screens/school_class_selection_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/market_owner_home_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/add_reward_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/edit_reward_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/orders_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/market_profile_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/market_account_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/market_notifications_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/order_history_screen.dart';
import 'package:me_plus/presentation/screens/market_owner/market_items_screen.dart';
import 'package:me_plus/presentation/screens/parent/parent_home_screen.dart';
import 'package:me_plus/presentation/screens/parent/child_activity_screen.dart';
import 'package:me_plus/presentation/screens/parent/kid_report_screen.dart';
import 'package:me_plus/presentation/screens/parent/parent_child_purchases_screen.dart';
import 'package:me_plus/presentation/screens/parent/parent_profile_screen.dart';
import 'package:me_plus/presentation/screens/parent/parent_account_screen.dart';
import 'package:me_plus/presentation/screens/parent/parent_notifications_screen.dart';

/// Application router configuration using GoRouter
class AppRouter {
  /// Helper method to wrap a widget with RoleBackHandler for non-home routes
  static Widget _wrapWithBackHandler(BuildContext context, GoRouterState state, Widget child) {
    return RoleBackHandler(
      currentRoute: state.uri.path,
      child: child,
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashCheckScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/google-signup-details',
        name: 'google-signup-details',
        builder: (context, state) => const GoogleSignupDetailsScreen(),
      ),
      GoRoute(
        path: '/signup/student',
        name: 'student-signup',
        builder: (context, state) => const StudentScreenSignUp(),
      ),
      GoRoute(
        path: '/signup/student/school-selection',
        name: 'school-class-selection',
        builder: (context, state) => const SchoolClassSelectionScreen(),
      ),
      GoRoute(
        path: '/signup/parent',
        name: 'parent-signup',
        builder: (context, state) => const ParentScreenSignUp(),
      ),
      GoRoute(
        path: '/signup/market-owner',
        name: 'market-owner-signup',
        builder: (context, state) => const MarketOwnerScreenSignUp(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/student',
        name: 'onboarding-student',
        builder: (context, state) =>
            const OnboardingScreen(role: UserRole.student),
      ),
      GoRoute(
        path: '/onboarding/parent',
        name: 'onboarding-parent',
        builder: (context, state) =>
            const OnboardingScreen(role: UserRole.parent),
      ),
      GoRoute(
        path: '/onboarding/market-owner',
        name: 'onboarding-market-owner',
        builder: (context, state) =>
            const OnboardingScreen(role: UserRole.marketOwner),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-code',
        name: 'verify-code',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: '/set-new-password',
        name: 'set-new-password',
        builder: (context, state) {
          final resetData = state.extra as Map<String, String>?;
          return SetNewPasswordScreen(resetData: resetData);
        },
      ),
      GoRoute(
        path: '/password-success',
        name: 'password-success',
        builder: (context, state) => const PasswordChangeSuccessScreen(),
      ),
      GoRoute(
        path: '/student/home',
        name: 'student-home',
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: '/student/store',
        name: 'student-store',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const StoreScreen(),
        ),
      ),
      GoRoute(
        path: '/student/top10',
        name: 'student-top10',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const Top10Screen(),
        ),
      ),
      GoRoute(
        path: '/student/notifications',
        name: 'student-notifications',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/student/activity',
        name: 'student-activity',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const ActivityScreen(),
        ),
      ),
      GoRoute(
        path: '/student/behavior',
        name: 'student-behavior',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const BehaviorScreen(),
        ),
      ),
      GoRoute(
        path: '/student/profile',
        name: 'student-profile',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/student/account',
        name: 'student-account',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const AccountScreen(),
        ),
      ),
      GoRoute(
        path: '/student/purchases',
        name: 'student-purchases',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const PurchasesScreen(),
        ),
      ),
      GoRoute(
        path: '/student/report-missing',
        name: 'student-report-missing',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const MissingRewardScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/home',
        name: 'market-owner-home',
        builder: (context, state) => const MarketOwnerHomeScreen(),
      ),
      GoRoute(
        path: '/market-owner/add-reward',
        name: 'market-owner-add-reward',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const AddRewardScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/edit-reward/:id',
        name: 'market-owner-edit-reward',
        builder: (context, state) {
          final reward = state.extra as StoreReward;
          return _wrapWithBackHandler(
            context,
            state,
            EditRewardScreen(reward: reward),
          );
        },
      ),
      GoRoute(
        path: '/market-owner/orders',
        name: 'market-owner-orders',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/profile',
        name: 'market-owner-profile',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const MarketProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/account',
        name: 'market-owner-account',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const MarketAccountScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/notifications',
        name: 'market-owner-notifications',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const MarketNotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/order-history',
        name: 'market-owner-order-history',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const OrderHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/market-owner/items',
        name: 'market-owner-items',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const MarketItemsScreen(),
        ),
      ),
      GoRoute(
        path: '/parent/home',
        name: 'parent-home',
        builder: (context, state) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: '/parent/child-activity/:kidId',
        name: 'parent-child-activity',
        builder: (context, state) {
          final kidId = state.pathParameters['kidId'] ?? '1';
          return _wrapWithBackHandler(
            context,
            state,
            ChildActivityScreen(kidId: kidId),
          );
        },
      ),
      GoRoute(
        path: '/parent/child-report/:kidId',
        name: 'parent-child-report',
        builder: (context, state) {
          final kidId = state.pathParameters['kidId'] ?? '1';
          final month = state.uri.queryParameters['month'];
          return _wrapWithBackHandler(
            context,
            state,
            ChildReportScreen(kidId: kidId, selectedMonth: month),
          );
        },
      ),
      GoRoute(
        path: '/parent/child-purchases/:kidId',
        name: 'parent-child-purchases',
        builder: (context, state) {
          final kidId = state.pathParameters['kidId'] ?? '1';
          final month = state.uri.queryParameters['month'];
          return _wrapWithBackHandler(
            context,
            state,
            ParentChildPurchasesScreen(kidId: kidId, selectedMonth: month),
          );
        },
      ),
      GoRoute(
        path: '/parent/profile',
        name: 'parent-profile',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const ParentProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/parent/account',
        name: 'parent-account',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const ParentAccountScreen(),
        ),
      ),
      GoRoute(
        path: '/parent/notifications',
        name: 'parent-notifications',
        builder: (context, state) => _wrapWithBackHandler(
          context,
          state,
          const ParentNotificationsScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
