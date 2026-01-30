import '../entities/dashboard_stats_entity.dart';
import '../repositories/vendor_repository.dart';

class GetDashboardStatsUseCase {
  final VendorRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<DashboardStatsEntity> call(String token) async {
    return await repository.getDashboardStats(token);
  }
}






