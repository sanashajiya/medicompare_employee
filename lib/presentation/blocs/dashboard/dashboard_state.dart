import '../../../domain/entities/dashboard_stats_entity.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStatsEntity stats;

  DashboardLoaded({required this.stats});
}

class DashboardLogoutSuccess extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}


