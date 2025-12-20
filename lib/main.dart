import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicompare_employee/presentation/blocs/auth/auth_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/auth_local_storage.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/blocs/draft/draft_bloc.dart';
import 'presentation/blocs/draft/draft_event.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initializeDependencies();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MedicompareEmployeeApp());
}

class MedicompareEmployeeApp extends StatelessWidget {
  const MedicompareEmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())],
      child: MaterialApp(
        title: 'Emp Medicompares',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final authStorage = sl<AuthLocalStorage>();

    // Check login status synchronously (SharedPreferences is already initialized)
    final isLoggedIn = authStorage.isLoggedIn();
    final savedUser = authStorage.getSavedUser();

    if (isLoggedIn && savedUser != null) {
      print('✅ User is logged in, navigating to DashboardScreen');
      return MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
          BlocProvider<DraftBloc>(
            create: (_) => sl<DraftBloc>()..add(DraftLoadCountRequested()),
          ),
        ],
        child: DashboardScreen(user: savedUser),
      );
    } else {
      print('🔐 User is not logged in, showing LoginScreen');
      return const LoginScreen();
    }
  }
}
