import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vendor_entity.dart';
import '../../../domain/usecases/get_vendor_details_usecase.dart';
import 'vendor_profile_screen.dart';

class VendorEditScreen extends StatefulWidget {
  final String vendorId;
  final UserEntity user;
  final VendorEntity? preloadedVendor;

  const VendorEditScreen({
    super.key,
    required this.vendorId,
    required this.user,
    this.preloadedVendor,
  });

  @override
  State<VendorEditScreen> createState() => _VendorEditScreenState();
}

class _VendorEditScreenState extends State<VendorEditScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  VendorEntity? _fetchedVendorDetails;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedVendor != null) {
      _fetchedVendorDetails = widget.preloadedVendor;
      _isLoading = false;
    } else {
      _fetchVendorDetails();
    }
  }

  Future<void> _fetchVendorDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getVendorDetailsUseCase = sl<GetVendorDetailsUseCase>();
      final vendorDetails = await getVendorDetailsUseCase(
        widget.vendorId,
        widget.user.token,
      );

      if (mounted) {
        setState(() {
          _fetchedVendorDetails = vendorDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(_errorMessage ?? 'Failed to load vendor details'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchVendorDetails();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we have data and are not loading, show the profile screen
    // This keeps it in the same widget tree, preserving providers
    if (!_isLoading && _fetchedVendorDetails != null) {
      return VendorProfileScreen(
        user: widget.user,
        vendorDetails: _fetchedVendorDetails,
        isEditMode: true,
      );
    }

    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loading Vendor Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading vendor details...'),
                ],
              )
            : _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading vendor details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _fetchVendorDetails();
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
