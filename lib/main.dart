import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:happy_pet_dashboard/l10n/app_localizations.dart';

import 'core/router/app_router.dart';
import 'core/services/persistence_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await SupabaseService.initialize();
  await PersistenceService.initialize();
  runApp(const HappyPetApp());
}

class HappyPetApp extends StatelessWidget {
  const HappyPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit()..loadSettings()),
        BlocProvider(
          lazy: false,
          create: (context) {
            final authRepository = AuthRepository();
            final cubit = AuthCubit(authRepository);
            setAuthCubit(cubit); // Inject into router
            return cubit;
          },
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Happy Pet Dashboard',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}



/**
 * Para Login / Cadastro:

Email: teste@happypet.com
Senha: 123456 (Mínimo de 6 caracteres)
Nome: Usuário Teste
 */