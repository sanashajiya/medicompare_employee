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
      // Get authentication token from local storage
      final user = authLocalStorage.getSavedUser();
      if (user == null || user.token.isEmpty) {
        emit(
          DashboardError(
            message: 'User not authenticated. Please login again.',
          ),
        );
        return;
      }

      // Fetch dashboard stats from API
      final stats = await getDashboardStatsUseCase(user.token);
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
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


