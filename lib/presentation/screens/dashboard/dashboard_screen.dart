import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/dashboard_stats_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../blocs/vendor_form/vendor_form_bloc.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import 'widgets/dashboard_action_buttons.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_stats_cards.dart';

class DashboardScreen extends StatefulWidget {
  final UserEntity user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<DashboardBloc>().add(DashboardLogoutRequested());
    }
  }

  void _navigateToVendorForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<VendorFormBloc>(
          create: (_) => sl<VendorFormBloc>(),
          child: HomeScreen(user: widget.user),
        ),
      ),
    );
  }

  void _handleDraftTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy - Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleAboutUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('About Us - Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardLogoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: DashboardAppBar(
          onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        endDrawer: DashboardDrawer(
          user: widget.user,
          onLogout: _handleLogout,
          onPrivacyPolicy: _handlePrivacyPolicy,
          onAboutUs: _handleAboutUs,
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = state is DashboardLoaded
                ? state.stats
                : const DashboardStatsEntity();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(DashboardLoadRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header/Banner Section
                    DashboardHeader(userName: widget.user.name),
                    const SizedBox(height: 24),

                    // Action Buttons Section
                    DashboardActionButtons(
                      onNewVendorTap: _navigateToVendorForm,
                      onDraftTap: _handleDraftTap,
                    ),
                    const SizedBox(height: 24),

                    // Statistics Cards Section
                    DashboardStatsCards(stats: stats),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
