import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/dashboard_stats_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../blocs/draft/draft_bloc.dart';
import '../../blocs/draft/draft_event.dart';
import '../../blocs/draft/draft_state.dart';
import '../../blocs/vendor_form/vendor_form_bloc.dart';
import '../../blocs/vendor_stepper/vendor_stepper_bloc.dart';
import '../../../core/constants/vendor_filter_type.dart';
import '../auth/login_screen.dart';
import '../draft_list/draft_list_screen.dart';
import '../vendor_list/vendor_list_screen.dart';
import '../vendor_profile/vendor_profile_screen.dart';
import 'widgets/dashboard_action_buttons.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_stats_cards.dart';
import 'package:url_launcher/url_launcher.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardBloc>().add(DashboardLoadRequested());
        // Ensure draft count is loaded
        context.read<DraftBloc>().add(DraftLoadCountRequested());
      }
    });
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
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<VendorFormBloc>(
                  create: (_) => sl<VendorFormBloc>(),
                ),
                BlocProvider<VendorStepperBloc>(
                  create: (_) => sl<VendorStepperBloc>(),
                ),
                BlocProvider<DraftBloc>.value(value: context.read<DraftBloc>()),
              ],
              child: VendorProfileScreen(user: widget.user),
            ),
          ),
        )
        .then((_) {
          // Refresh draft count when returning from vendor form
          if (mounted) {
            context.read<DraftBloc>().add(DraftLoadCountRequested());
          }
        });
  }

  void _handleDraftTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DraftBloc>(),
          child: DraftListScreen(user: widget.user),
        ),
      ),
    );
  }

  void _handleVendorStatCardTap(VendorFilterType filterType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            VendorListScreen(user: widget.user, filterType: filterType),
      ),
    );
  }

  void _handlePrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://medicompares.com/policies/privacy-policy',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Privacy Policy')),
      );
    }
  }

  void _handleAboutUs() async {
    final Uri url = Uri.parse(
      'https://medicompares.com/policies/terms-and-conditions',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Terms and Conditions')),
      );
    }
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
        body: BlocBuilder<DraftBloc, DraftState>(
          builder: (context, draftState) {
            final draftCount = draftState is DraftCountLoaded
                ? draftState.count
                : (draftState is DraftListLoaded
                      ? draftState.drafts.length
                      : 0);

            return BlocBuilder<DashboardBloc, DashboardState>(
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
                          draftCount: draftCount,
                        ),
                        const SizedBox(height: 24),

                        // Statistics Cards Section
                        DashboardStatsCards(
                          stats: stats,
                          onCardTap: _handleVendorStatCardTap,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
