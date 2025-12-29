import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/local/auth_local_storage.dart';
import '../../../domain/usecases/get_dashboard_stats_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AuthLocalStorage authLocalStorage;
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  DashboardBloc({
    required this.authLocalStorage,
    required this.getDashboardStatsUseCase,
  }) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      print('\n═══════════════════════════════════════════════════════');
      print('📊 [DashboardBloc] Loading dashboard stats...');
      print('═══════════════════════════════════════════════════════');

      // Get authentication token from local storage
      final user = authLocalStorage.getSavedUser();
      
      if (user == null) {
        print('❌ [DashboardBloc] User is null in SharedPreferences');
        print('═══════════════════════════════════════════════════════\n');
        emit(
          DashboardError(
            message: 'User not authenticated. Please login again.',
          ),
        );
        return;
      }

      if (user.token.isEmpty) {
        print('❌ [DashboardBloc] User token is empty');
        print('❌ [DashboardBloc] User: ${user.email}');
        print('═══════════════════════════════════════════════════════\n');
        emit(
          DashboardError(
            message: 'Authentication token missing. Please login again.',
          ),
        );
        return;
      }

      print('✅ [DashboardBloc] User found: ${user.email}');
      print('✅ [DashboardBloc] Token: ${user.token.substring(0, 20)}...');

      // Fetch dashboard stats from API
      final stats = await getDashboardStatsUseCase(user.token);
      print('✅ [DashboardBloc] Dashboard stats loaded successfully');
      print('═══════════════════════════════════════════════════════\n');
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      print('❌ [DashboardBloc] Error loading dashboard: $e');
      print('═══════════════════════════════════════════════════════\n');
      emit(
        DashboardError(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _onLogoutRequested(
    DashboardLogoutRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await authLocalStorage.clearLoginStatus();
    emit(DashboardLogoutSuccess());
  }
}


