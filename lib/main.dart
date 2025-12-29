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

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<Widget> _screenFuture;

  @override
  void initState() {
    super.initState();
    _screenFuture = _determineInitialScreen();
  }

  Future<Widget> _determineInitialScreen() async {
    try {
      print('\n═══════════════════════════════════════════════════════');
      print('🔐 [AppInitializer] Starting app initialization...');
      print('═══════════════════════════════════════════════════════\n');

      final authStorage = sl<AuthLocalStorage>();

      // Give SharedPreferences a moment to ensure it's fully initialized
      await Future.delayed(const Duration(milliseconds: 100));

      // Check login status synchronously (SharedPreferences is initialized in DI)
      final isLoggedIn = authStorage.isLoggedIn();
      print('🔍 [AppInitializer] isLoggedIn: $isLoggedIn');

      if (isLoggedIn) {
        final savedUser = authStorage.getSavedUser();
        if (savedUser != null && savedUser.token.isNotEmpty) {
          print('✅ [AppInitializer] User is logged in');
          print(
            '✅ [AppInitializer] User: ${savedUser.name} (${savedUser.email})',
          );
          print(
            '✅ [AppInitializer] Token exists: ${savedUser.token.substring(0, 20)}...',
          );
          print('═══════════════════════════════════════════════════════\n');

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
          print(
            '⚠️  [AppInitializer] isLoggedIn=true but user is null or token is empty',
          );
          print('⚠️  [AppInitializer] Showing login screen instead');
          // Clear corrupted login state
          await authStorage.clearLoginStatus();
        }
      } else {
        print('🔐 [AppInitializer] User is not logged in');
        print('═══════════════════════════════════════════════════════\n');
      }

      return const LoginScreen();
    } catch (e) {
      print('❌ [AppInitializer] Error during initialization: $e');
      print('═══════════════════════════════════════════════════════\n');
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _screenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print('❌ [AppInitializer] FutureBuilder error: ${snapshot.error}');
          return const LoginScreen();
        }

        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}

