import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/local/auth_local_storage.dart';
import '../../../domain/entities/dashboard_stats_entity.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AuthLocalStorage authLocalStorage;

  DashboardBloc({required this.authLocalStorage}) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      // For now, use dummy static values
      // Later this will be connected to APIs
      const stats = DashboardStatsEntity(
        totalVendors: 156,
        approvedVendors: 98,
        pendingVendors: 42,
        rejectedVendors: 16,
      );
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
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
