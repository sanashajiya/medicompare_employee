import 'package:flutter/material.dart';
import '../../../../core/constants/vendor_filter_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsCards extends StatelessWidget {
  final DashboardStatsEntity stats;
  final Function(VendorFilterType)? onCardTap;

  const DashboardStatsCards({super.key, required this.stats, this.onCardTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendor Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              icon: Icons.groups_rounded,
              label: 'Total Vendors',
              count: stats.totalVendors,
              color: AppColors.info,
              filterType: VendorFilterType.all,
              onTap: onCardTap,
            ),
            _StatCard(
              icon: Icons.check_circle_rounded,
              label: 'Approved',
              count: stats.approvedVendors,
              color: AppColors.success,
              filterType: VendorFilterType.approved,
              onTap: onCardTap,
            ),
            _StatCard(
              icon: Icons.pending_rounded,
              label: 'Pending approval',
              count: stats.pendingVendors,
              color: AppColors.warning,
              filterType: VendorFilterType.pending,
              onTap: onCardTap,
            ),
            _StatCard(
              icon: Icons.cancel_rounded,
              label: 'Rejected',
              count: stats.rejectedVendors,
              color: AppColors.error,
              filterType: VendorFilterType.rejected,
              onTap: onCardTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VendorFilterType filterType;
  final Function(VendorFilterType)? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.filterType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap!(filterType) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




