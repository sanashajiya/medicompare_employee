import '../entities/dashboard_stats_entity.dart';
import '../repositories/vendor_repository.dart';

class GetDashboardStatsUseCase {
  final VendorRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<DashboardStatsEntity> call(String token) async {
    // We fetch the full vendor list and calculate stats locally
    // to ensure consistency and properly handle "processing" status as "pending"
    final vendors = await repository.getVendorList(token);

    int approvedCount = 0;
    int rejectedCount = 0;
    int pendingCount = 0;

    for (final vendor in vendors) {
      final status = vendor.verifyStatus?.toLowerCase().trim() ?? '';

      if (status == 'approved') {
        approvedCount++;
      } else if (status == 'rejected') {
        rejectedCount++;
      } else {
        // "processing", "pending", or unhandled status -> Pending Approval
        pendingCount++;
      }
    }

    return DashboardStatsEntity(
      totalVendors: vendors.length,
      approvedVendors: approvedCount,
      pendingVendors: pendingCount,
      rejectedVendors: rejectedCount,
    );
  }
}
