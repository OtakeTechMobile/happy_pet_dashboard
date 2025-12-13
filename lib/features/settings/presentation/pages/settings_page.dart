import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final isDark = state.themeMode == ThemeMode.dark;
          final isPt = state.locale.languageCode == 'pt';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, l10n.general),
              SwitchListTile(
                title: Text(l10n.darkMode),
                value: isDark,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleTheme(value);
                },
              ),
              ListTile(
                title: Text(l10n.language),
                subtitle: Text(isPt ? 'Português' : 'English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLanguageDialog(context, isPt);
                },
              ),
              const Divider(),
              _buildSectionHeader(context, l10n.notifications),
              SwitchListTile(title: Text(l10n.emailNotifications), value: true, onChanged: (value) {}),
              SwitchListTile(title: Text(l10n.pushNotifications), value: false, onChanged: (value) {}),
              const Divider(),
              _buildSectionHeader(context, l10n.account),
              ListTile(
                title: const Text('Hotel Profile'),
                leading: const Icon(Icons.business),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/hotel');
                },
              ),
              ListTile(
                title: Text(l10n.profile),
                leading: const Icon(Icons.person_outline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              ListTile(
                title: Text(l10n.logout),
                leading: const Icon(Icons.logout, color: Colors.red),
                textColor: Colors.red,
                onTap: () async {
                  await context.read<AuthCubit>().signOut();
                  // Router redirect should handle navigation to login
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isPt) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.language),
        children: [
          SimpleDialogOption(
            onPressed: () {
              context.read<SettingsCubit>().setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: Row(
              children: [if (!isPt) const Icon(Icons.check, size: 16), const SizedBox(width: 8), const Text('English')],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context.read<SettingsCubit>().setLocale(const Locale('pt'));
              Navigator.pop(context);
            },
            child: Row(
              children: [
                if (isPt) const Icon(Icons.check, size: 16),
                const SizedBox(width: 8),
                const Text('Português'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
