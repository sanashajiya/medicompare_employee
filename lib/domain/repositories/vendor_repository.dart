import '../entities/dashboard_stats_entity.dart';
import '../entities/vendor_entity.dart';

abstract class VendorRepository {
  Future<VendorEntity> createVendor(VendorEntity vendor, String token);
  Future<DashboardStatsEntity> getDashboardStats(String token);
}

