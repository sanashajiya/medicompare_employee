import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/vendor_filter_type.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vendor_model.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vendor_entity.dart';
import '../../../domain/entities/vendor_list_item_entity.dart';
import '../../blocs/draft/draft_bloc.dart';
import '../../blocs/vendor_form/vendor_form_bloc.dart';
import '../../blocs/vendor_list/vendor_list_bloc.dart';
import '../../blocs/vendor_list/vendor_list_event.dart';
import '../../blocs/vendor_list/vendor_list_state.dart';
import '../../blocs/vendor_stepper/vendor_stepper_bloc.dart';
import '../vendor_profile/vendor_edit_screen.dart';

class VendorListScreen extends StatefulWidget {
  final UserEntity user;
  final VendorFilterType filterType;

  const VendorListScreen({
    super.key,
    required this.user,
    this.filterType = VendorFilterType.all,
  });

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getAppBarTitle() {
    switch (widget.filterType) {
      case VendorFilterType.all:
        return 'All Vendors';
      case VendorFilterType.approved:
        return 'Approved Vendors';
      case VendorFilterType.pending:
        return 'Pending Vendors';
      case VendorFilterType.rejected:
        return 'Rejected Vendors';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VendorListBloc>()
        ..add(VendorListLoadRequested(widget.user.token, widget.filterType)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
        ),
        body: BlocBuilder<VendorListBloc, VendorListState>(
          builder: (context, state) {
            if (state is VendorListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VendorListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading vendors',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VendorListBloc>().add(
                          VendorListLoadRequested(
                            widget.user.token,
                            widget.filterType,
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is VendorListLoaded) {
              final vendors = state.vendors;

              // Filter vendors based on filterType and search query
              final filteredVendors = _filterVendors(vendors);

              return Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.surface,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, mobile, vendor ID...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            return value.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  // Vendor List
                  Expanded(
                    child: filteredVendors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchController.text.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.business_outlined,
                                  size: 80,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'No Results Found'
                                      : widget.filterType ==
                                            VendorFilterType.all
                                      ? 'No Vendors'
                                      : 'No Vendors Found',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Try adjusting your search terms'
                                      : widget.filterType ==
                                            VendorFilterType.all
                                      ? 'No vendors found'
                                      : 'No vendors match the selected filter',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<VendorListBloc>().add(
                                VendorListRefreshRequested(
                                  widget.user.token,
                                  widget.filterType,
                                ),
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredVendors.length,
                              itemBuilder: (context, index) {
                                final vendor = filteredVendors[index];
                                return _VendorCard(
                                  vendor: vendor,
                                  onTap: () {
                                    // 4️⃣ Add Defensive Logging (Temporary)
                                    print('\n🔍 VENDOR TAP DETECTED');
                                    print('   Vendor Name: ${vendor.fullName}');
                                    print('   Vendor _id: ${vendor.id}');
                                    print(
                                      '   Vendor vendorsId: ${vendor.vendorsId}',
                                    );

                                    // 5️⃣ UI Safety Check
                                    // The details API expects the MongoDB _id (vendor.id)
                                    // The 'vendorsId' (e.g. VND-...) is a business ID and causes 404s on the ID-based endpoints
                                    final idToPass = vendor.id;
                                    print(
                                      '   🆔 ID being sent to details API: $idToPass',
                                    );

                                    if (idToPass.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to open vendor details. Invalid ID.',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }

                                    // Try to parse rawData for preloading
                                    VendorEntity? preloadedVendor;
                                    if (vendor.rawData != null) {
                                      try {
                                        print(
                                          '🔍 Preloading vendor data from list...',
                                        );
                                        preloadedVendor =
                                            VendorModel.fromVendorListJson(
                                              vendor.rawData!,
                                            );
                                        print(
                                          '✅ Vendor data preloaded successfully!',
                                        );
                                      } catch (e) {
                                        print(
                                          '❌ Error preloading vendor data: $e',
                                        );
                                      }
                                    } else {
                                      print(
                                        '⚠️ No rawData available for preloading.',
                                      );
                                    }

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider<VendorFormBloc>(
                                              create: (_) =>
                                                  sl<VendorFormBloc>(),
                                            ),
                                            BlocProvider<VendorStepperBloc>(
                                              create: (_) =>
                                                  sl<VendorStepperBloc>(),
                                            ),
                                            BlocProvider<DraftBloc>(
                                              create: (_) => sl<DraftBloc>(),
                                            ),
                                          ],
                                          child: VendorEditScreen(
                                            vendorId: idToPass,
                                            user: widget.user,
                                            preloadedVendor: preloadedVendor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  List<VendorListItemEntity> _filterVendors(
    List<VendorListItemEntity> vendors,
  ) {
    // First filter by status
    List<VendorListItemEntity> statusFiltered = vendors;
    if (widget.filterType != VendorFilterType.all) {
      statusFiltered = vendors.where((vendor) {
        final status = vendor.verifyStatus?.toLowerCase().trim() ?? '';

        switch (widget.filterType) {
          case VendorFilterType.approved:
            return status == 'approved';
          case VendorFilterType.rejected:
            return status == 'rejected';
          case VendorFilterType.pending:
            // Match dashboard stats logic: Any non-approved/non-rejected status is Pending
            // This includes 'pending', 'processing', and others
            return status != 'approved' && status != 'rejected';
          case VendorFilterType.all:
            return true;
        }
      }).toList();
    }

    // Then filter by search query
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isEmpty) {
      return statusFiltered;
    }

    return statusFiltered.where((vendor) {
      // Search in multiple fields
      final fullName = vendor.fullName.toLowerCase();
      final firstName = vendor.firstName.toLowerCase();
      final lastName = vendor.lastName.toLowerCase();
      final email = vendor.email.toLowerCase();
      final mobile = vendor.mobile.toLowerCase();
      final vendorId = vendor.vendorsId?.toLowerCase() ?? '';
      final businessName = vendor.businessName?.toLowerCase() ?? '';
      final businessEmail = vendor.businessEmail?.toLowerCase() ?? '';

      return fullName.contains(searchQuery) ||
          firstName.contains(searchQuery) ||
          lastName.contains(searchQuery) ||
          email.contains(searchQuery) ||
          mobile.contains(searchQuery) ||
          vendorId.contains(searchQuery) ||
          businessName.contains(searchQuery) ||
          businessEmail.contains(searchQuery);
    }).toList();
  }
}

class _VendorCard extends StatelessWidget {
  final VendorListItemEntity vendor;
  final VoidCallback? onTap;

  const _VendorCard({required this.vendor, this.onTap});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'processing':
        return 'Processing';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(vendor.verifyStatus);
    final statusLabel = _getStatusLabel(vendor.verifyStatus);
    final statusIcon = _getStatusIcon(vendor.verifyStatus);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row with Status Badge
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Business
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          vendor.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(height: 4),
                        Text(
                          vendor.businessName ?? '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // const Divider(height: 1),
              // const SizedBox(height: 12),
              // Contact Information
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: vendor.email,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Mobile',
                value: vendor.mobile,
              ),
              if (vendor.vendorsId != null && vendor.vendorsId!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Vendor ID',
                  value: vendor.vendorsId!,
                ),
              ],
              if (vendor.businessEmail != null &&
                  vendor.businessEmail!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.business_outlined,
                  label: 'Business Email',
                  value: vendor.businessEmail!,
                ),
              ],
              if (vendor.createdAt != null) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: _formatDate(vendor.createdAt),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
