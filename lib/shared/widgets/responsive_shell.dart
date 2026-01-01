import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/enums/app_enums.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../l10n/app_localizations.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const ResponsiveShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final currentPath = state.uri.path;
    final l10n = AppLocalizations.of(context)!;

    // Access auth state to determine role
    final authState = context.watch<AuthCubit>().state;
    final userRole = authState.userProfile?.role;
    final isAdminOrOwner = userRole == UserRole.admin || userRole == UserRole.owner;

    // Mapped routes to handle index matching dynamically
    // Indices: 0: Dashboard, 1: Pets, 2: Appointments, 3: Clients, 4: Settings (if present)
    // We need to adjust `getSelectedIndex` and `onDestinationSelected` because the list size changes.
    // Let's create a list of (Route, NavigationDestination)
    final menuConfig = [
      (
        route: '/dashboard',
        item: NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: l10n.dashboard,
        ),
      ),
      (
        route: '/pets',
        item: NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: l10n.pets),
      ),
      (
        route: '/patio',
        item: NavigationDestination(
          icon: Icon(Icons.tablet_android_outlined),
          selectedIcon: Icon(Icons.tablet_android),
          label: 'Pátio',
        ),
      ),
      (
        route: '/appointments',
        item: NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: l10n.appointments,
        ),
      ),
      (
        route: '/clients',
        item: NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: l10n.clients,
        ),
      ),
    ];

    if (isAdminOrOwner) {
      if (userRole == UserRole.admin) {
        menuConfig.add((
          route: '/admin/hotels',
          item: NavigationDestination(
            icon: Icon(Icons.corporate_fare_outlined),
            selectedIcon: Icon(Icons.corporate_fare),
            label: 'Gestão de Creches',
          ),
        ));
      }

      menuConfig.add((
        route: '/settings',
        item: NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: l10n.settings,
        ),
      ));
    }

    final menuItems = menuConfig.map((e) => e.item).toList();

    // Helper to get index from path (simplified for now)
    // Helper to get index from path
    int getSelectedIndex() {
      // Find the index of the route that the current path starts with
      // Reverse check to match specific routes first (though they are all top level except potentially /hotel which isn't in menu)
      for (int i = 0; i < menuConfig.length; i++) {
        if (currentPath.startsWith(menuConfig[i].route)) {
          return i;
        }
      }
      return 0; // Default to Dashboard
    }

    void onDestinationSelected(int index) {
      if (index >= 0 && index < menuConfig.length) {
        context.go(menuConfig[index].route);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Image.asset('assets/images/logo.png', height: 40)),
            const SizedBox(width: 8),
            Flexible(child: const Text('Happy Pet Dashboard')),
          ],
        ),
        actions: [
          // 5 App Bar Items as requested
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.message_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Text('A'),
            ),
          ),
        ],
      ),
      drawer: !isDesktop
          ? NavigationDrawer(
              selectedIndex: getSelectedIndex(),
              onDestinationSelected: onDestinationSelected,
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(28, 16, 16, 10), child: Text('Menu')),
                ...menuItems.map(
                  (dest) => NavigationDrawerDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    label: Text(dest.label),
                  ),
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: getSelectedIndex(),
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: menuItems
                  .map(
                    (dest) => NavigationRailDestination(
                      icon: dest.icon,
                      selectedIcon: dest.selectedIcon,
                      label: Text(dest.label),
                    ),
                  )
                  .toList(),
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
