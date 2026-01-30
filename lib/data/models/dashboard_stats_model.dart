import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalVendors,
    required super.approvedVendors,
    required super.pendingVendors,
    required super.rejectedVendors,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested structure from API response
    // Response structure: { "success": true, "message": "...", "data": { "totalVendor": 0, ... } }
    final data = json['data'] ?? {};

    return DashboardStatsModel(
      totalVendors: data['totalVendor'] as int? ?? 0,
      approvedVendors: data['approvedVendor'] as int? ?? 0,
      pendingVendors: data['pendingVendor'] as int? ?? 0,
      rejectedVendors: data['rejectedVendor'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVendor': totalVendors,
      'approvedVendor': approvedVendors,
      'pendingVendor': pendingVendors,
      'rejectedVendor': rejectedVendors,
    };
  }
}






