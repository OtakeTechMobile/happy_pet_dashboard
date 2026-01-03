import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/enums/app_enums.dart';
import '../../features/admin/presentation/pages/hotel_owners_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/clients/pages/clients_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/patio_dashboard_page.dart';
import '../../features/hotel/presentation/pages/hotel_page.dart';
import '../../features/pets/presentation/pages/pets_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/responsive_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

// Ideally this should be provided via DI or InheritedWidget context, but for static router definition:
late final AuthCubit _authCubit;

void setAuthCubit(AuthCubit cubit) {
  _authCubit = cubit;
}

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: _AuthStream(_authCubit),
    redirect: (context, state) {
      final authStatus = _authCubit.state.status;
      if (authStatus == AuthStatus.unknown) return null;

      final isLoggedIn = authStatus == AuthStatus.authenticated;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      // Role-based Access Control
      if (isLoggedIn) {
        final userRole = _authCubit.state.userProfile?.role;
        final currentPath = state.uri.path;

        // Restricted routes for admin only
        if (currentPath.startsWith('/admin/hotels')) {
          if (userRole != UserRole.admin) return '/dashboard';
        }

        // Restricted routes for Admin/Owner only (NOT STAFF)
        final ownerRestrictedRoutes = ['/hotel'];
        final isOwnerRestricted = ownerRestrictedRoutes.any((route) => currentPath.startsWith(route));

        if (isOwnerRestricted) {
          final hasAccess = userRole == UserRole.admin || userRole == UserRole.owner;
          if (!hasAccess) {
            return '/dashboard';
          }
        }

        // Settings is available for all but content might differ (handled in settings page)
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ResponsiveShell(state: state, child: child);
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/patio', builder: (context, state) => const PatioDashboardPage()),
          GoRoute(path: '/pets', builder: (context, state) => const PetsPage()),
          GoRoute(path: '/clients', builder: (context, state) => const ClientsPage()),
          GoRoute(path: '/appointments', builder: (context, state) => const AppointmentsPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          GoRoute(path: '/hotel', builder: (context, state) => const HotelPage()),
          GoRoute(path: '/admin/hotels', builder: (context, state) => const HotelOwnersPage()),
        ],
      ),
    ],
  );
}

class _AuthStream extends ChangeNotifier {
  final AuthCubit cubit;
  late final StreamSubscription subscription;

  _AuthStream(this.cubit) {
    subscription = cubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
